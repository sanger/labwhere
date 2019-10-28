class Api::Labwares::LocationsController < ApiController
  def create
    render json: labware_locations
  end

  private

  def labware_locations
    LabwareLocations.build(labwares)
  end

  def labwares
    Labware
      .includes(:location, { coordinate: :location })
      .by_barcode(params[:barcodes])
      .where("coordinate_id IS NOT NULL OR location_id IS NOT NULL")
  end
end
