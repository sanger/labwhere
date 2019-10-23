class CoordinateSerializer < ActiveModel::V08::Serializer
  
  attributes :id, :position, :row, :column, :labware, :location

  # the labware barcode of the coordinate
  def labware
    object.labware.barcode
  end

  # the location barcode for the coordinate
  def location
    object.location.barcode
  end

end