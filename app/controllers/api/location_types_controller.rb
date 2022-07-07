# frozen_string_literal: true

# Api::LocationTypesController
class Api::LocationTypesController < ApiController
  def index
    render json: LocationType.all
  end

  def show
    render json: current_resource
  end

  def create
    @location_type = LocationTypeForm.new
    process_location_type
  end

  def update
    @location_type = LocationTypeForm.new(current_resource)
    process_location_type
  end

  private

  def current_resource
    LocationType.find(params[:id]) if params[:id]
  end

  def process_location_type
    if @location_type.submit(params)
      render json: @location_type, serializer: LocationTypeSerializer
    else
      render json: { errors: @location_type.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
