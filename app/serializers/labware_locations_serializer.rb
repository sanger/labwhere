class LabwareLocationsSerializer < ActiveModel::Serializer
  has_many :locations, serializer: LocationLiteSerializer
end
