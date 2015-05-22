##
#
# Audit form includes ActiveModel::Model and all its wonderment.
#
# An audit form will do three things:
# * Create an object for the model and check it for errors.
# * Check whether the user exists and whether the use is authorised to created the record.
# * Add an audit record.
#
# === Usage
# * The name of the model is inferred from the name of the form.
# * The name must follow convention ModelForm.
# * The +set_attributes+ method should contain any attributes that are whitelisted and
#   will be added to the model.
#
# Example:
#
#  class MyModelForm
#   include AuditForm
#   set_attributes :attr_a, :attr_b
#  end
#
# Usage in controller:
#  
#  def new
#   @my_model = MyModelForm.new
#  end
#
#  def create
#   @my_model = MyModelForm.new
#   if @my_model.submit(params)
#    ...
#   end
#  end
#
#  def edit
#   @my_model = MyModelForm.new(MyModel.find(params[:id]))
#  end
#
#  def update
#   @my_model = MyModelForm.new(MyModel.find(params[:id]))
#   if @my_model.submit(params)
#    ...
#   end
#  end
#

module AuditForm

  extend ActiveSupport::Concern
  include ActiveModel::Model 
  
  module ClassMethods

    ##
    # This method is important to ensure whitelisted attributes are added to the model.
    # Only pass attributes that are to be whitelisted.
    def set_attributes(*attributes)
      delegate *attributes, to: :model

      define_method :model_attributes do
        attributes
      end
    end
  end
  
  included do

    include HashAttributes

    _model = self.to_s.gsub("Form","")

    define_singleton_method :model_name do
      ActiveModel::Name.new(_model.constantize, nil, _model)
    end

    attr_accessor :user_code
    attr_reader :model, :controller, :action, :current_user
    alias_attribute _model.underscore.to_sym, :model

    validate :check_for_errors, unless: Proc.new { |model| model.destroying? }
    validate :check_user
    validate :before_destroy, if: Proc.new { |model| model.destroying? }

    delegate :id, to: :model
  end

  ##
  # If an object is passed it will be assigned otherwise a new one is created.
  # This covers new/edit and destroy action.
  def initialize(object = nil)
    @model = object || self.model_name.name.constantize.new
  end

  ##
  # Check whether the user is valid, save the model if it is valid
  # and create an audit record.
  # Returns boolean depending on whether everything is valid.
  def submit(params)
    set_params_attributes(self.model_name.i18n_key, params)
    set_current_user
    model.attributes = params[self.model_name.i18n_key].slice(*model_attributes).permit!
    if valid?
      model.save
      model.create_audit(current_user, action)
    else
      false
    end
  end

  ##
  # Will destroy the record if the user is authorised and the record can be destroyed.
  # Will create an audit record.
  def destroy(params)
    set_attributes(params)
    set_current_user
    if valid?
      model.create_audit(current_user, action)
      model.destroy
    else
      false
    end
  end

  ##
  # This is necessary for any forms.
  # Checks whether the record already exists.
  def persisted?
    model.id?
  end

  ##
  # Checks whether this is passed from the destroy action.
  def destroying?
    action == "destroy"
  end

private

  def set_current_user
    @current_user = User.find_by_code(user_code)
  end

  def check_for_errors
    unless model.valid?
      model.errors.each do |key, value|
        errors.add key, value
      end
    end
  end

  def check_user
    UserValidator.new.validate(self)
  end

  def before_destroy
  end

end