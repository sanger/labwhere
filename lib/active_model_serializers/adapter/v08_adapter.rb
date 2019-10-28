# frozen_string_literal: true

module ActiveModelSerializers
  module Adapter
    class V08Adapter < ActiveModelSerializers::Adapter::Base
      def serializable_hash(options = nil)
        options ||= {}

        if serializer.respond_to?(:each)
          if serializer.root
            delegate_to_json_adapter(options)
          else
            serializable_hash_for_collection(options)
          end
        else
          serializable_hash_for_single_resource(options)
        end
      end

      def serializable_hash_for_collection(options)
        serializer.map do |s|
          V08Adapter.new(s, instance_options)
                    .serializable_hash(options)
        end
      end

      def serializable_hash_for_single_resource(options)
        if serializer.object.is_a?(ActiveModel::Serializer)
          # It is recommended that you add some logging here to indicate
          # places that should get converted to eventually allow for this
          # adapter to get removed.
          @serializer = serializer.object
        end

        if serializer.root
          delegate_to_json_adapter(options)
        else
          options = serialization_options(options)
          serializer.serializable_hash(instance_options, options, self)
        end
      end

      def delegate_to_json_adapter(options)
        ActiveModelSerializers::Adapter::Json
          .new(serializer, instance_options)
          .serializable_hash(options)
      end
    end
  end
end
