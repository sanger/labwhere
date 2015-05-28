class Api::LocationsController < ApplicationController
  def show
    render json: current_resource
  end

  def create
    @location = LocationProcessor.new
    process_location
  end

  def update
    @location = LocationProcessor.new(current_resource)
    process_location
  end

private

  def current_resource
    Location.find_by(barcode: params[:barcode])
  end

  def process_location
    if @location.submit(params)
      render json: @location
    else
      render json: { errors: @location.errors.full_messages}, status: :unprocessable_entity
    end
  end

end