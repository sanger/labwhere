# frozen_string_literal: true

# Serializer for the LabwareLocations model
class LabwareLocationsSerializer < ActiveModel::Serializer
  has_many :locations, serializer: LocationLiteSerializer
end
