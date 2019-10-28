module ActiveModelExtension
  def klass
    @klass
  end
end

ActiveModel::Name.include ActiveModelExtension
