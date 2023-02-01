# frozen_string_literal: true

# Api::LabwaresController
class Api::LabwaresController < ApiController
  def index
    # doesn't currently include a basic index function, returning all labwares, but could in future
    render json: labwares_by_location
  end

  def show
    render json: current_resource
  end

  def create
    uploader = ManifestUploader.new(json: permitted_params, user_code: params[:user_code], controller: 'api/labwares',
                                    action: 'create')

    if uploader.run
      render json: Labware.by_barcode_known_locations(uploader.labwares), each_serializer: LabwareLiteSerializer
    else
      render json: { errors: uploader.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def by_barcode
    if request.params['known'] == 'true'
      render json: Labware.by_barcode_known_locations(params[:barcodes]), each_serializer: LabwareLiteSerializer
    else
      render json: Labware.by_barcode(params[:barcodes]), each_serializer: LabwareLiteSerializer
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

  def permitted_params
    params.permit(:action, :controller, labwares: %i[location_barcode labware_barcode])
  end
end
