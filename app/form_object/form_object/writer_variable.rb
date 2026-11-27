# frozen_string_literal: true

module FormObject
  # WriterVariable
  class WriterVariable < ReaderVariable
    # rubocop:disable-next Lint/MissingSuper
    def initialize(model, name)
      @name = name
      model.send(:attr_accessor, name)
    end
  end
end
