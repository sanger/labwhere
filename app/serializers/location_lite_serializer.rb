class LocationLiteSerializer < ActiveModel::Serializer
  attributes :id, :labware_barcode, :row, :column
end
