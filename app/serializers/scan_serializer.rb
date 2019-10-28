# Serializer for Scan
# includes created_at and updated_at
class ScanSerializer < ActiveModel::V08::Serializer
  attributes :message

  has_one :location

  include SerializerDates
end
