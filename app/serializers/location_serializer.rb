class LocationSerializer < ActiveModel::Serializer
  
  self.root = false

  attributes :id, :name, :parent, :container, :status, :location_type_id, :labwares, :audits, :barcode, :children

  include SerializerDates

  def parent
    object.parent.name
  end

  def labwares
    api_location_labwares_path(object.barcode)
  end

  def audits
    api_location_audits_path(object.barcode)
  end

  def children
    api_location_children_path(object.barcode)
  end

end
