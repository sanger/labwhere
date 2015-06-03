class LocationLabwareSerializer < ActiveModel::Serializer

  self.root = false

  attributes :barcode, :history

  include SerializerDates

  def history
    api_labware_histories_path(object.barcode)
  end
end
