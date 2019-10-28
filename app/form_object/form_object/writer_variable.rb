module FormObject
  class WriterVariable < ReaderVariable
    def initialize(model, name)
      @name = name
      model.send(:attr_accessor, name)
    end
  end
end
