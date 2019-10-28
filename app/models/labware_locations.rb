class LabwareLocations < ActiveModelSerializers::Model
  attributes :locations

  def self.build(labwares)
    location_lites = labwares.map do |labware|
      LocationLite.new(
        id: labware.location.id,
        labware_barcode: labware.barcode,
        row: labware.coordinate.row,
        column: labware.coordinate.column
      )
    end

    new(locations: location_lites)
  end
end
