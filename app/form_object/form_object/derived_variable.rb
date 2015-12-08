module FormObject
  class DerivedVariable < ReaderVariable
      
      def initialize(model, hsh)
        @name, @call = hsh.to_a.flatten
        model.send(:attr_reader, name)
      end

      def assign(object, value)
        object.instance_variable_set instance, object.send(call)
      end

    private

      attr_reader :call


  end
end