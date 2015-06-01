class LabwareSerializer < ActiveModel::Serializer

  self.root = false

  attributes :barcode, :history

  has_one :location

  def history
    api_labware_histories_path(object.barcode)
  end
end
