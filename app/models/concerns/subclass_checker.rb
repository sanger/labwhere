
module SubclassChecker

  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods

    def subclasses(*classes)
      options = classes.extract_options!
      classes.each do |klass|
        object_type = if options[:suffix]
          "#{klass.to_s.capitalize}#{self.to_s.capitalize}"
        else
          "#{klass.to_s.capitalize}"
        end
        define_method "#{klass.to_s}?" do
          type == object_type
        end
      end
    end
  end
  
end