# frozen_string_literal: true

class Api::Labwares::SearchesController < ApiController
  def create
    # Little complex, but the includes here is eager loading as many associated models as possible
    render json: Labware.includes([{ location: location_includes }, { coordinate: coordinate_includes }])
                        .by_barcode(params[:barcodes]), include: ["location.coordinates"]
  end

  private

  # Include all the models a location needs to eager load
  def location_includes
    [:internal_parent, { coordinates: [:labware, :location] }]
  end

  # Include all the models a coordinate needs to eager load
  def coordinate_includes
    [{ location: location_includes }]
  end
end
