##
#
# Audit form includes ActiveModel::Model and all its wonderment.
#
# An audit form will do three things:
#  * Create an object for the model and check it for errors.
#  * Check whether the user exists and whether the use is authorised to created the record.
#  * Add an audit record.
#
# = Usage
#  * The name of the model is inferred from the name of the form.
#  * The name must follow convention ModelForm.
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

    validate :check_for_errors, :check_user

    delegate :id, to: :model
  end

  def initialize(object = nil)
    @model = object || self.model_name.name.constantize.new
  end

  def submit(params)
    set_params_attributes(self.model_name.i18n_key, params)
    @current_user = User.find_by_code(user_code)
    model.attributes = params[self.model_name.i18n_key].slice(*model_attributes).permit!
    if valid?
      model.save
      Audit.add(model, current_user, action)
    else
      false
    end
  end

  def persisted?
    model.id?
  end

private

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

end