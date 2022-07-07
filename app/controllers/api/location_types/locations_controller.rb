# frozen_string_literal: true

# Api::LocationTypes::LocationsController
class Api::LocationTypes::LocationsController < ApiController
  def index
    render json: current_resource
  end

  private

  def current_resource
    LocationType.find(params[:location_type_id]).locations if params[:location_type_id]
  end
end
