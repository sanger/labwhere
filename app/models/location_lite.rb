# frozen_string_literal: true

# Class LocationLite
class LocationLite < ActiveModelSerializers::Model
  attributes :id, :labware_barcode, :row, :column
end
