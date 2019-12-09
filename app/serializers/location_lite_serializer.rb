# frozen_string_literal: true

class LocationLiteSerializer < ActiveModel::Serializer
  attributes :id, :labware_barcode, :row, :column
end
