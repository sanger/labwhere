# frozen_string_literal: true

# TODO: I think this needs to be removed so we can return to simpler times.
module FormObject
  extend ActiveSupport::Concern
  include ActiveModel::Model
  include ActiveModel::Serialization

  # Provides a middleman between views and models.
  # A form object will allow you to assign permitted attributes.
  # It will also allow you to carry out other functions such as authorisation and adding audit records.
  # Convention states that the name must be in the format of the model followed by Form e.g. MyModelForm relates to MyModel.
  # It will set the ActiveModel name to the underlying model name for use in views.
  #
  # The set_attributes method accepts a list of attributes which will be assigned on submit and are permitted.
  # These must be attributes of the model.
  # The form object can be initialized with an existing object
  # The submit method accepts parameters of type ActionController::Parameters of format { my_model: { attr_a: "a", attr_b: "b"}}
  # The submit method will assign any form variables, assign the model attributes will validate the model and carry out any other
  # specific validations that are added. It will then save the model if it is valid.
  # The after_validate method allows you to change which actions are carried out post validation.
  # The after_submit callback allows you to specify actions which can be carried out after a successful submit.
  # Each form object will automatically assign controller and action variables if the parameters come from a controller and will
  # also assign the parameters to an instance variable.
  # Each object will also have an attribute called model which relates to the underlying model this is also aliased to the name of the model.
  # e.g. if model is called MyModel there will an attribute called my_model.

  # Usage:
  #  class MyModel
  #   validates_presence_of :attr_a
  #  end
  #
  #  class MyModelForm
  #   include FormObject
  #
  #   set_attributes :attr_a, :attr_b
  #   set_form_attributes :user_code
  #   validate :check_user
  #
  #   after_validate do
  #    my_model.save
  #    Audit.create(user_code, my_model)
  #   end
  #
  #   def check_user
  #    UserValidator.new.validate(self)
  #   end
  #  end
  #
  #  my_model_form = MyModelForm.new
  #  my_model_form.submit(ActionController::Parameters.new({user_code: 1234, my_model: attr_a: "a", attr_b: "b"}))
  #   => true
  #  my_model_form.my_model # => <# MyModel: id: 1, attr_a: "a", attr_b: "b" >
  #  my_model_form.user_code # => 1234
  #
  #  my_model_form = MyModelForm.new
  #  my_model_form.submit(ActionController::Parameters.new({user_code: 1234, my_model: attr_a: nil, attr_b: "b"}))
  #   => false
  #  my_model_form.my_model # => <# MyModel: id: nil, attr_a: nil, attr_b: "b" >
  #  my_model_form.errors.full_messages # => ["attr a can't be blank."]
  #
  #  my_model_form = MyModelForm.new
  #  my_model_form.submit(ActionController::Parameters.new({user_code: nil, my_model: attr_a: "a", attr_b: "b"}))
  #   => false
  #  my_model_form.my_model # => <# MyModel: id: nil, attr_a: "a", attr_b: "b" >
  #  my_model_form.errors.full_messages # => ["user does not exist."]
  #

  included do
    _model = self.to_s.gsub("Form", "")

    class_attribute :form_variables
    self.form_variables = FormObject::FormVariables.new(self, _model.underscore.to_sym, [:controller, :action])

    validate :check_for_errors

    define_singleton_method :model_name do
      ActiveModel::Name.new(_model.constantize)
    end

    attr_reader :model

    alias_attribute self.form_variables.model_key, :model

    delegate :id, :created_at, :updated_at, :to_json, to: :model

    define_model_callbacks :submit, only: :after
    define_model_callbacks :save_model, only: :after
    define_model_callbacks :assigning_model_variables, only: :after
  end

  module ClassMethods
    # Set the whitelist of attributes that will be assigned to the model.
    def set_attributes(*attributes)
      delegate *attributes, to: :model

      define_method :model_attributes do
        attributes
      end
    end

    # Set the list of form variables which will be assigned on submit.
    def set_form_variables(*variables)
      self.form_variables.add(*variables)
    end

    # modify the actions which will be carried out after a successful validation.
    def after_validate(&block)
      define_method :save_if_valid do
        run_transaction do
          instance_eval &block
        end
      end
    end
  end

  # If no argument is passed a new model is created otherwise the passed object is assigned
  def initialize(object = nil)
    @model = object || self.model_name.klass.new
  end

  def fill_model(params)
    self.form_variables.assign(self, params)
    if self.respond_to?(:model_attributes)
      run_callbacks :assigning_model_variables do
        model.attributes = params[self.model_name.i18n_key].slice(*model_attributes).permit!
      end
    end
  end

  # form variables are assigned, attributes are assigned to the model object validate and save the object
  # and run any callbacks.
  def submit(params)
    run_callbacks :submit do
      fill_model(params)
      save_if_valid
    end
  end

  # Has the model previously been persisted?
  def persisted?
    model.id?
  end

  # Validate the model. If it is valid run an ActiveRecord transaction with any passed block.
  # The standard validation is to validate the ActiveRecord model plus any specified validation.
  # If the model is valid and any transaction runs successfully then return true otherwise return false.
  def save_if_valid
    run_transaction do
      model.save
    end
  end

  def save_model
    run_callbacks :save_model do
      model.save
    end
  end

  private

  def check_for_errors
    add_errors unless model.valid?
  end

  def add_errors
    model.errors.each do |key, value|
      errors.add key, value
    end
  end

  # rubocop:disable Style/ExplicitBlockArgument
  def run_transaction(&block)
    if valid?
      begin
        ActiveRecord::Base.transaction do
          yield
        end
        true
      rescue
        false
      end
    else
      false
    end
  end
  # rubocop:enable Style/ExplicitBlockArgument
end
