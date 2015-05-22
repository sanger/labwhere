module ActionDispatch
  module Routing
    class Mapper
      def scope_module(&block)
        scope module: parent_resource.controller do
          yield if block_given?
        end
      end
    end
  end
end