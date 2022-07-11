# frozen_string_literal: true

# Api::LocationTypes::AuditsController
class Api::LocationTypes::AuditsController < ApiController
  def index
    render json: current_resource
  end

  private

  def current_resource
    LocationType.find(params[:location_type_id]).audits if params[:location_type_id]
  end
end
