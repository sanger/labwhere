class CoordinateSerializer < ActiveModel::Serializer
  
  attributes :position, :row, :column, :labware

  def labware
    object.labware.barcode
  end

end