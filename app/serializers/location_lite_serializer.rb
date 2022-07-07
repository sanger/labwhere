# frozen_string_literal: true

# Serializer for the LocationLite model
class LocationLiteSerializer < ActiveModel::Serializer
  attributes :id, :labware_barcode, :row, :column
end
