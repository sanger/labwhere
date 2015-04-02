class LocationTypesController < ApplicationController
  def index
  end

  def new
    @location_type = LocationType.new
  end

  def create
    @location_type = LocationType.new(location_type_params)

    if @location_type.save
      flash[:notice] = "Location type successfully created"
      redirect_to @location_type
    else
      render :new
    end
  end

  def show
    @location_type = current_resource
  end

private

  def current_resource
    @current_resource ||= LocationType.find(params[:id]) if params[:id]
  end

  def location_type_params
    params.require(:location_type).permit(:name)
  end

end
