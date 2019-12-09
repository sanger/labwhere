# frozen_string_literal: true

module ActiveModel
  module V08
    class Serializer < ActiveModel::Serializer
      include Rails.application.routes.url_helpers

      # AMS 0.8 would delegate method calls from within the serializer to the
      # object.
      def method_missing(*args)
        method = args.first
        read_attribute_for_serialization(method)
      end

      alias_method :options, :instance_options

      # Since attributes could be read from the `object` via `method_missing`,
      # the `try` method did not behave as before. This patches `try` with the
      # original implementation plus the addition of
      # ` || object.respond_to?(a.first, true)` to check if the object responded to
      # the given method.
      def try(*a, &b)
        if a.empty? || respond_to?(a.first, true) || object.respond_to?(a.first, true)
          try!(*a, &b)
        end
      end

      # AMS 0.8 would return nil if the serializer was initialized with a nil
      # resource.
      def serializable_hash(adapter_options = nil,
                            options = {},
                            adapter_instance =
                                self.class.serialization_adapter_instance)
        object.nil? ? nil : super
      end
    end
  end
end
