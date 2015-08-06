class Api::Locations::CoordinatesController < ApiController
  def show
    render json: current_resource
  end

private

  def current_resource
    if params[:location_barcode] && params[:available]
      Location.find_by_code(params[:location_barcode]).available_coordinates(params[:available].to_i)
    end
  end
end
