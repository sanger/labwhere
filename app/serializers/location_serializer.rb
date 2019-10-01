# Serializer for Location
# includes created_at and updated_at
class LocationSerializer < ActiveModel::V08::Serializer
  
  attributes :id, :name, :parent, :container, :status, :location_type_id, :audits, :barcode, :rows, :columns, :parentage

  include SerializerDates

  ##
  # If the parent is not valid return its name
  # otherwise return a link to the parent
  def parent
    if object.internal_parent.nil? || object.internal_parent.unknown?
      NullLocation.new.name
    else
      api_location_path(object.internal_parent.barcode)
    end
  end

  ##
  # Link to the audits for the location
  def audits
    api_location_audits_path(object.barcode)
  end

end
