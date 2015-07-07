##
# Serializer for the History model
# includes created_at and updated_at
class HistorySerializer < ActiveModel::Serializer

  self.root = false

  attributes :user, :location

  include SerializerDates

  ##
  # user login for the associated scan.
  def user
    object.scan.user.login
  end

  ##
  # Name for the associated location.
  def location
    object.scan.location.name
  end
end
