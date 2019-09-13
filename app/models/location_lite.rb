class LocationLite < ActiveModelSerializers::Model
  attributes :id, :labware_barcode, :row, :column
end
