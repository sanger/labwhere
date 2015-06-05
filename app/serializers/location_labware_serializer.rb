class LocationLabwareSerializer < ActiveModel::Serializer

  self.root = false

  attributes :barcode, :history, :coordinate

  include SerializerDates

  def history
    api_labware_histories_path(object.barcode)
  end

  def coordinate
    object.coordinate.name
  end
end
