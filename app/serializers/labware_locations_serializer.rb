# frozen_string_literal: true

class LabwareLocationsSerializer < ActiveModel::Serializer
  has_many :locations, serializer: LocationLiteSerializer
end
