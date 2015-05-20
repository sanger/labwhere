class LocationsController < ApplicationController

  before_action :locations, only: [:index]
  
  def index
  end

  def new
    @location = LocationForm.new
  end

  def show
    @location = current_resource
  end

  def create
    @location = LocationForm.new
    if @location.submit(params)
      redirect_to locations_path, notice: "Location successfully created"
    else
      render :new
    end
  end

  def edit
    @location = LocationForm.new(current_resource)
  end

  def update
    @location = LocationForm.new(current_resource)
    if @location.submit(params)
      redirect_to locations_path, notice: "Location successfully updated"
    else
      render :edit
    end
  end

  def deactivate
    @location = current_resource
    @location.deactivate
    redirect_to locations_path, notice: "Location successfully deactivated"
  end

  def activate
    @location = current_resource
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

  def current_resource
    @current_resource ||= Location.includes(:labwares).find(params[:id]) if params[:id]
  end

end
