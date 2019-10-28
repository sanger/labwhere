module FormObject
  # Allows you to set the form variables for the form object
  # Controller variables are assigned via the initializer and model variables are assigned via the add method.
  # The first argument in initialize is the key for the model.

  class FormVariables
    attr_reader :model_key, :readers, :writers, :variables, :derived

    def initialize(model, model_key = nil, readers = [])
      @model = model
      @model_key = model_key || model.to_s.underscore.to_sym
      @variables, @readers, @writers, @derived = {}, {}, {}, {}
      @variables[:params] = ReaderVariable.new(model, :params)
      readers.each do |var|
        _add(ReaderVariable, @readers, var)
      end
    end

    # Add the provided variable to the model variables
    def add(*vars)
      vars.each do |var|
        if var.is_a? Hash
          _add(DerivedVariable, @derived, var)
        else
          _add(WriterVariable, @writers, var)
        end
      end
    end

    def find(name)
      @variables[name]
    end

    # Set up instance variables for controller and model.
    #
    def assign(object, params)
      variables[:params].assign(object, params)
      assign_by_type(readers, object, params)
      if params.has_key?(model_key)
        assign_writers_and_derived(object, params[model_key])
      else
        assign_writers_and_derived(object, params)
      end
    end

    private

    attr_reader :model

    def assign_writers_and_derived(object, params)
      assign_by_type(writers, object, params)
      assign_by_type(derived, object, params)
    end

    def assign_by_type(hsh, object, params)
      hsh.each do |k, v|
        v.assign(object, params[k])
      end
    end

    def _add(type, instance, var)
      variable = type.new(model, var)
      instance[variable.name] = variable
      @variables[variable.name] = variable
    end
  end
end
