module ActiveModelExtension
  def klass
    @klass
  end
end

ActiveModel::Name.send(:include, ActiveModelExtension)