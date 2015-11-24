module FormObject

  # Allows you to set the form variables for the form object
  # Controller variables are assigned via the initializer and model variables are assigned via the add method.
  # The first argument in initialize is the key for the model.

  class FormVariables

    attr_reader :model_key

    def initialize(*args)
      @model_key = args.shift
      @controller_variables = {}
      _add controller_variables, args
      @model_variables = {}
    end

    # Returns the keys for all of the controller variables
    def controller
      controller_variables.keys
    end

    # Returns the keys for all the model variables
    def model
      model_variables.keys
    end

    # Add the provided variable to the model variables
    def add(*vars)
      _add model_variables, vars
    end

    # Find the associated variable name in the controller or model variables.
    def find(name)
      controller_variables[name] || model_variables[name]
    end

    # Set up instance variables for controller and model.
    #
    def assign_all(object, params)
      controller_variables.each do |k, v|
        object.instance_variable_set v.instance, v.assign(object, k == :params ? params : params[k])
      end

      model_variables.each do |k, v|
        object.instance_variable_set v.instance, v.assign(object, params[model_key][k])
      end
    end

    class FormVariable

      attr_reader :name

      def initialize(variable)
        if variable.is_a? Hash
          @name, @call = variable.to_a.flatten
        else
          @name = variable
        end
      end

      def assign(object, value)
        if call
          object.send(call, value)
        else
          value
        end
      end

      def instance
        "@#{name}"
      end

    private

      attr_reader :call
      
    end

  private

    attr_reader :controller_variables, :model_variables

    def _add(hsh, vars)
      vars.each do |variable|
        _variable = FormVariable.new(variable)
        hsh[_variable.name] = _variable
      end
    end
  end
end