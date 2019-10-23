class Api::Locations::DescendantsController < ApiController

  def index
    render json: current_resource
  end

private

  def current_resource
    locations = find_descendants if params[:location_barcode]
    locations = AvailableCoordinatesQuery.call(locations, permitted_params[:min_available_coordinates]) if permitted_params.has_key? :min_available_coordinates
    locations
  end

  def permitted_params
    params.permit(:min_available_coordinates)
  end

  def find_descendants
    Location.find_by_code(params[:location_barcode])
        .descendants
        .includes(coordinates: [:labware, :location])
  end

end