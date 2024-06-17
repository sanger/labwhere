# frozen_string_literal: true

# Api::LocationsController
class Api::LocationsController < ApiController
  before_action :permitted_params, only: %i[create update]

  def index
    render json: Location.by_root
  end

  def show
    render json: current_resource
  end

  def create
    @location = LocationForm.new
    process_location(@location.submit(permitted_params))
  end

  def update
    @location = LocationForm.new(current_resource)
    process_location(@location.update(permitted_params))
  end

  # Retrieves information about a location based on its barcode.
  # @param params The request parameters. Expected to contain a `:barcode` key with the barcode of the location.
  # For example, to get information about a location with barcode 'lw-location-1-1', the URL would be:
  # GET /api/locations/info?barcode=lw-location-1-1
  #
  # @return A response with a JSON body. If a location is found, the body contains the labwares 
  # and the maximum descendant depth.
  #  e.g { labwares: [labware1, labware2], depth: 2 }
  #  If no location is found, the body contains an error. e.g { errors: ['Location not found'] }

  def info
    location = Location.find_by(barcode: params[:barcode])
    if location
      render json: { labwares: location.labwares.to_a, depth: location.max_descendant_depth }
    else
      render json: { errors: ['Location not found'] }, status: :unprocessable_entity
    end
  end

  private

  def current_resource
    Location.find_by_code(params[:barcode]) if params[:barcode]
  end

  def process_location(succeeded)
    if succeeded
      render json: @location, serializer: "#{@location.type}Serializer".constantize
    else
      render json: { errors: @location.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def permitted_params
    location_attrs = Location.new.attributes.keys.map(&:to_sym)
    params.permit(:action, :controller, location: [*location_attrs,
                                                   :parent_id,
                                                   :user_code,
                                                   :start_from,
                                                   :end_to,
                                                   :reserve,
                                                   :coordinateable])
  end
end
