# Serializer for Location Type
# includes created_at and updated_at
class LocationTypeSerializer < ActiveModel::Serializer

  self.root = false

  attributes :id, :name, :locations, :audits

  include SerializerDates

  ##
  # Link to locations for current location type
  def locations
    api_location_type_locations_path(object)
  end

  ##
  # Link to audits for current location type
  def audits
    api_location_type_audits_path(object)

  end
end
