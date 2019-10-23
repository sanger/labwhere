##
# Serializer for the Audit model
# includes created_at and updated_at
class AuditSerializer < ActiveModel::V08::Serializer
  attributes :user, :record_data, :action, :auditable_type

  include SerializerDates

  ##
  # Return the user login for an Audit.
  def user
    object.user.login
  end
end
