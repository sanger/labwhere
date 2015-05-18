class LocationTypesController < ApplicationController

  before_action :location_types, only: [:index]

  def index
  end

  def new
    @location_type = LocationTypeForm.new
  end

  def create
    @location_type = LocationTypeForm.new
    if @location_type.submit(params)
      redirect_to location_types_path, notice: "Location type successfully created"
    else
      render :new
    end
  end

  def edit
    @location_type = LocationTypeForm.new(current_resource)
  end

  def update
    @location_type = LocationTypeForm.new(current_resource)
    if @location_type.submit(params)
      redirect_to location_types_path, notice: "Location type successfully updated"
    else
      render :edit
    end
  end

  def show
    @location_type = current_resource
  end

  def delete
    @record = LocationTypeForm.new(current_resource)
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @record = LocationTypeForm.new(current_resource)
    respond_to do |format|
      if @record.destroy(params)
        flash_keep "Location type successfully deleted"
        format.js { render js: "window.location.pathname='#{location_types_path}'" }
      else
        format.js 
      end
    end
  end

protected

  def location_types
    @location_type ||= LocationType.ordered
  end

  helper_method :location_types

private

  def current_resource
    @current_resource ||= LocationType.find(params[:id]) if params[:id]
  end

end
