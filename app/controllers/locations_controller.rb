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
      flash[:notice] = "Location successfully created"
      redirect_to locations_path
    else
      render :new
    end
  end

  def edit
  end

  def update

    if @location.update_attributes(location_params)
      flash[:notice] = "Location successfully updated"
      redirect_to locations_path
    else
      render :edit
    end
  end

  def destroy
    if @location.destroy
      notice = "Location successfully deactivated"
    else
      notice = "Unable to deactivate Location"
    end
    flash[:notice] = notice
    redirect_to locations_path
  end

protected

  def locations
    @locations ||= Location.all
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
    params.require(:location).permit(:name, :location_type_id, :parent_id, :container, :active, labwares_attributes: [:id, :barcode, :_destroy])
  end

end
