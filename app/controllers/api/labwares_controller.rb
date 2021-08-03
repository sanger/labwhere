# frozen_string_literal: true

class Api::LabwaresController < ApiController
  def show
    render json: current_resource
  end

  def index
    # doesn't currently include a basic index function, returning all labwares, but could in future
    render json: labwares_by_location
  end

  def create
    uploader = ManifestUploader.new(json: permitted_params, user_code: params[:user_code], controller: "api/labwares", action: "create")

    if uploader.run
      render json: labwares_by_barcode_known_locations(uploader.labwares), each_serializer: LabwareLiteSerializer
    else
      render json: { errors: uploader.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def by_barcode
    if request.params["known"] == "true"
      render json: labwares_by_barcode_known_locations(params[:barcodes]), each_serializer: LabwareLiteSerializer
    else
      render json: labwares_by_barcode, each_serializer: LabwareLiteSerializer
    end
  end

  private

  def current_resource
    Labware.find_by_barcode(params[:barcode])
  end

  def labwares_by_location
    # expects url param of location barcode(s)
    # for example, ?location_barcodes=lw-uk-biocentre-mk-6-3662,lw-reefer-1-33
    location_barcodes = params[:location_barcodes]
    return unless location_barcodes

    Labware.by_location_barcode(location_barcodes.split(','))
  end

  def labwares_by_barcode
    Labware.by_barcode(params[:barcodes])
  end

  def labwares_by_barcode_known_locations(barcodes)
    Labware.by_barcode_known_locations(barcodes)
  end

  def permitted_params
    params.permit(:action, :controller, labwares: [:location_barcode, :labware_barcode])
  end
end
