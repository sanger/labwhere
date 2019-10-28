# frozen_string_literal: true

module FormObject
  class ReaderVariable
    attr_reader :name

    def initialize(model, name)
      @name = name
      model.send(:attr_reader, name)
    end

    def assign(object, value)
      object.instance_variable_set instance, value
    end

    def instance
      "@#{name}"
    end
  end
end
