# frozen_string_literal: true

class Api::Locations::CoordinatesController < ApiController
  before_action :coordinate, only: [:update]

  def index
    render json: coordinates
  end

  def update
    coordinate_form = CoordinateForm.new(coordinate)

    if coordinate_form.submit(params)
      render json: coordinate
    else
      render json: { errors: coordinate_form.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def coordinates
    ordered_location.nil? ? [] : ordered_location.coordinates
  end

  def ordered_location
    OrderedLocation
      .includes(coordinates: [:labware, :location])
      .find_by_code(params[:location_barcode])
  end

  def coordinate
    @coordinate ||= Coordinate.find(params[:id])
  end
end
