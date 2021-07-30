# frozen_string_literal: true

class Api::LabwaresController < ApiController
  def show
    render json: current_resource
  end

  def index
    # doesn't currently include a basic index function, returning all labwares, but could in future
    render json: labwares_by_location
  end

  # We would like the end point to accept a json body
  # e.g. { labwares: [{ location_barcode: 'loc-1', labware_barcode: 'DN1'},...]}
  # The call should be performant - to be agreed?
  # The event that should be triggered is uploaded_from_manifest
  # TODO add to docs
  # TODO: check PAM user on UAT, and see what type of user they are.
  # update permissions to allow PAM user type
  # The call should be authenticated in the body
  # They will send a user login in the request. We need to check it exists.
  # It is used for the audit trail so we know who did it. PAM have a standard user.
  def create
    uploader = ManifestUploader.new(json: permitted_params, current_user: current_user, controller: "api/labwares", action: 'create')

    if uploader.run
      render json: { message: "successful" }
    else
      render json: { errors: uploader.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def by_barcode
    if request.params["known"] == "true"
      render json: labwares_by_barcode_known_locations, each_serializer: LabwareLiteSerializer
    else
      render json: labwares_by_barcode, each_serializer: LabwareLiteSerializer
    end
  end

  private

  def current_user
    User.find_by_code(params[:user_code]) if params[:user_code]
  end

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

  def permitted_params
    params.permit(:action, :controller, labwares: [:location_barcode, :labware_barcode])
  end
end
