# frozen_string_literal: true

module FormObject
  class WriterVariable < ReaderVariable
    # rubocop:disable Lint/MissingSuper
    def initialize(model, name)
      @name = name
      model.send(:attr_accessor, name)
    end
    # rubocop:enable Lint/MissingSuper
  end
end
