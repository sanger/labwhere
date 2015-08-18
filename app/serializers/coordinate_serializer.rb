class CoordinateSerializer < ActiveModel::Serializer
  
  attributes :position, :row, :column, :labware, :location

  def labware
    object.labware.barcode
  end

  def location
    object.location.barcode
  end

end