class LocationsController < ApplicationController

  before_action :set_location, except: [:index, :new, :create]
  before_action :locations, only: [:index]
  
  def index
  end

  def new
    @location = Location.new
  end

  def show
  end

  def create
    @location = Location.new(location_params)

    if @location.save
      redirect_to locations_path, notice: "Location successfully created"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @location.update_attributes(location_params)
      redirect_to locations_path, notice: "Location successfully updated"
    else
      render :edit
    end
  end

  def deactivate
    @location.deactivate
    redirect_to locations_path, notice: "Location successfully deactivated"
  end

  def activate
    @location.activate
    redirect_to locations_path, notice: "Location successfully activated"
  end

protected

  def locations
    @locations ||= if params[:location_type_id]
      LocationType.find(params[:location_type_id]).locations
    else
      Location.without_unknown
    end
  end

  helper_method :locations

private

  def set_location
    @location = current_resource
  end

  def current_resource
    @current_resource ||= Location.includes(:labwares).find(params[:id]) if params[:id]
  end
  
  def location_params
    params.require(:location).permit(:name, :location_type_id, :parent_id, :container)
  end

end
