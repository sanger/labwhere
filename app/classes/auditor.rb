module Auditor
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

    _model = self.to_s.remove_last_word

    define_singleton_method :model_name do
      ActiveModel::Name.new(_model.constantize, nil, _model)
    end

    attr_accessor :user_code
    attr_reader :model, :controller, :action, :current_user
    alias_attribute _model.underscore.to_sym, :model

    validate :check_for_errors, unless: Proc.new { |model| model.destroying? }
    validate :check_user
    validate :before_destroy, if: Proc.new { |model| model.destroying? }

    delegate :id, :to_json, to: :model

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
  # TODO: Improve the way this is done so when the module is included with some change
  # then only super should need to be called instead of overriding submit method
  def submit(params)

    set_instance_variables(params)
    set_current_user
    set_model_attributes(params)
    save_if_valid
    
  end

  ##
  # Will destroy the record if the user is authorised and the record can be destroyed.
  # Will create an audit record.
  def destroy(params)
    set_attributes(params)
    set_current_user
    destroy_if_valid
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

  def set_instance_variables(params)
    set_params_attributes(self.model_name.i18n_key, params)
  end

  def set_model_attributes(params)
    model.attributes = params[self.model_name.i18n_key].slice(*model_attributes).permit!
  end

  def save_if_valid
    if valid?
      model.save
      create_audit
    else
      false
    end
  end

  def destroy_if_valid
    if valid?
      create_audit
      model.destroy
    else
      false
    end
  end

  def create_audit
    model.create_audit(current_user, action)
  end

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