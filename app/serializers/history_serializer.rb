class HistorySerializer < ActiveModel::Serializer

  self.root = false

  attributes :user, :location

  include SerializerDates

  def user
    object.scan.user.login
  end

  def location
    object.scan.location.name
  end
end
