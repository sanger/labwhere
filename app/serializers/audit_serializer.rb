class AuditSerializer < ActiveModel::Serializer
  attributes :user, :record_data, :action, :auditable_type

  include SerializerDates

  def user
    object.user.login
  end
end
