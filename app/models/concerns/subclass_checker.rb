# frozen_string_literal: true

module SubclassChecker
  extend ActiveSupport::Concern

  module ClassMethods
    def has_subclasses(*classes)
      options = classes.extract_options!
      classes.each do |klass|
        object_type = klass_name(klass, options)
        define_method method_name(klass) do
          type == object_type
        end
      end
    end

    def klass_name(klass, options)
      if options[:suffix]
        "#{build_klass_name(klass)}#{to_s.capitalize}"
      else
        build_klass_name(klass)
      end
    end

    def method_name(klass)
      name = klass.to_s
      name.include?('_') ? "#{name.split('_').first}?" : "#{name}?"
    end

    private

    def build_klass_name(klass)
      name = klass.to_s
      name.include?('_') ? name.camelize : name.capitalize
    end
  end
end
