##
# Serializer for the Labware specifically for Locations
# includes created_at and updated_at
class LocationLabwareSerializer < ActiveModel::Serializer

  self.root = false

  attributes :barcode, :history

  include SerializerDates

  ##
  # Link to the history for the current labware
  def history
    api_labware_histories_path(object.barcode)
  end

end
