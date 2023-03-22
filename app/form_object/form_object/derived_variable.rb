# frozen_string_literal: true

module FormObject
  # DerivedVariable
  class DerivedVariable < ReaderVariable
    def initialize(model, hsh)
      name, @call = hsh.to_a.flatten
      super(model, name)
    end

    def assign(object, _value)
      object.instance_variable_set instance, object.send(call)
    end

    private

    attr_reader :call
  end
end
