class LocationTypeSerializer < ActiveModel::Serializer

  self.root = false

  attributes :name, :locations, :audits

  include SerializerDates

  def locations
    api_location_type_locations_path(object)
  end

  def audits
    api_location_type_audits_path(object)

  end
end
