class LocationTypes::LocationsController < ApplicationController

  before_action :locations, only: [:index]
  
  def index
  end

protected

  def locations
    LocationType.find(params[:location_type_id]).locations if params[:location_type_id]
  end

  helper_method :locations

end