class Api::LocationsController < ApiController

  def index
    render json: Location.without_unknown
  end

  def show
    render json: current_resource
  end

  def create
    @location = LocationForm.new
    process_location
  end

  def update
    @location = LocationForm.new(current_resource)
    process_location
  end

private

  def current_resource
    Location.find_by_code(params[:barcode]) if params[:barcode]
  end

  def process_location
    if @location.submit(params)
      render json: @location, serializer: LocationSerializer
    else
      render json: { errors: @location.errors.full_messages}, status: :unprocessable_entity
    end
  end

end