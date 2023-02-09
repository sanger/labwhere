# frozen_string_literal: true

# LocationTypesController
class LocationTypesController < ApplicationController
  before_action :location_types, only: [:index]
  before_action :set_location_type, except: [:index]

  def index; end

  def show; end
  def new; end

  def edit; end

  def create
    if @location_type.submit(params)
      redirect_to location_types_path, notice: I18n.t('success.messages.created', resource: 'Location type')
    else
      render :new
    end
  end

  def update
    if @location_type.submit(params)
      redirect_to location_types_path, notice: I18n.t('success.messages.updated', resource: 'Location type')
    else
      render :edit
    end
  end

  def delete
    respond_to do |format|
      format.js
    end
  end

  def destroy
    respond_to do |format|
      if @location_type.destroy(params)
        flash_keep 'Location type successfully deleted'
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

  def set_location_type
    @location_type = LocationTypeForm.new(current_resource)
  end

  helper_method :location_types

  private

  def current_resource
    @current_resource ||= LocationType.find(params[:id]) if params[:id]
  end
end
