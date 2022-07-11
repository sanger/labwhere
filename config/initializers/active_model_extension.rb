# frozen_string_literal: true

# ActiveModelExtension - find out which class it is.
module ActiveModelExtension
  def klass
    @klass
  end
end

ActiveModel::Name.include ActiveModelExtension
