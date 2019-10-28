class UnorderedLocationSerializer < LocationSerializer
  attributes :labwares, :children

  # #
  # Link to the labwares for the location
  def labwares
    api_location_labwares_path(object.barcode)
  end

  ##
  # Link to the children for the location
  def children
    api_location_children_path(object.barcode)
  end
end
