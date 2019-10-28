# frozen_string_literal: true

##
# Serializer for the Labware
class LabwareSerializer < ActiveModel::V08::Serializer
  attributes :barcode, :audits

  include SerializerDates

  has_one :location

  ##
  # Link to the audits for the location
  def audits
    api_labware_audits_path(object.barcode)
  end
end
