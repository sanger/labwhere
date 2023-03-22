# frozen_string_literal: true

module FormObject
  # DerivedVariable
  class DerivedVariable < ReaderVariable
    # rubocop:disable Lint/MissingSuper
    def initialize(model, hsh)
      @name, @call = hsh.to_a.flatten
      model.send(:attr_reader, name)
    end
    # rubocop:enable Lint/MissingSuper

    def assign(object, _value)
      object.instance_variable_set instance, object.send(call)
    end

    private

    attr_reader :call
  end
end
