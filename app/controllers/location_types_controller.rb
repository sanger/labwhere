class LocationTypesController < ApplicationController

  before_filter :location_types, only: [:index]

  def index
  end

  def new
    @location_type = LocationType.new
  end

  def create
    @location_type = LocationType.new(location_type_params)

    if @location_type.save
      flash[:notice] = "Location type successfully created"
      redirect_to location_types_path
    else
      render :new
    end
  end

  def edit
    @location_type = current_resource
  end

  def update
    @location_type = current_resource

    if @location_type.update_attributes(location_type_params)
      flash[:notice] = "Location type successfully updated"
      redirect_to location_types_path
    else
      render :edit
    end
  end

  def show
    @location_type = current_resource
  end

  def destroy
    @location_type = current_resource
    if @location_type.destroy
      notice = "Location type successfully deleted"
    else
      notice = "Unable to delete Location type"
    end
    flash[:notice] = notice
    redirect_to location_types_path
  end

protected

  def location_types
    @location_types ||= LocationType.all
  end

  helper_method :location_types

private

  def current_resource
    @current_resource ||= LocationType.find(params[:id]) if params[:id]
  end

  def location_type_params
    params.require(:location_type).permit(:name)
  end

end
