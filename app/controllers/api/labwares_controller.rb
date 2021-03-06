# frozen_string_literal: true

class Api::LabwaresController < ApiController
  def show
    render json: current_resource
  end

  def index
    # doesn't currently include a basic index function, returning all labwares, but could in future
    render json: labwares_by_location
  end

  def by_barcode
    if request.params["known"] == "true"
      render json: labwares_by_barcode_known_locations, each_serializer: LabwareLiteSerializer
    else
      render json: labwares_by_barcode, each_serializer: LabwareLiteSerializer
    end
  end

  private

  def current_resource
    Labware.find_by_code(params[:barcode]) if params[:barcode]
  end

  def labwares_by_location
    # expects url param of location barcode(s)
    # for example, ?location_barcodes=lw-uk-biocentre-mk-6-3662,lw-reefer-1-33
    location_barcodes = params[:location_barcodes]
    return unless location_barcodes

    Labware.joins(:location).where(locations: { barcode: location_barcodes.split(',') })
  end

  def labwares_by_barcode
    barcodes = params[:barcodes]
    return [] unless barcodes

    Labware.by_barcode(barcodes)
  end

  def labwares_by_barcode_known_locations
    barcodes = params[:barcodes]
    return [] unless barcodes

    Labware.by_barcode_known_locations(barcodes)
  end
end
