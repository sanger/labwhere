# frozen_string_literal: true

# LocationsController
class LocationsController < ApplicationController
  before_action :locations, only: [:index]
  before_action :set_location, except: %i[index activate deactivate]
  before_action :permitted_params, only: %i[create update]

  def index; end

  def new; end

  def show
    @location = current_resource
  end

  def create
    if @location.submit(permitted_params)
      redirect_to locations_path, notice: I18n.t('success.messages.created', resource: 'Location(s)')
    else
      render :new
    end
  end

  def edit; end

  def update
    if @location.update(permitted_params)
      redirect_to locations_path, notice: I18n.t('success.messages.updated', resource: 'Location')
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
      if @location.destroy(params)
        @message = "Location '#{@location.name}' successfully deleted"
        @message_type = 'notice'
      else
        @message = "Delete failed for location '#{@location.name}'"
        @message_type = 'alert'
      end
      format.js { render 'locations/destroy' }
    end
  end

  def deactivate
    @location = current_resource
    @location.deactivate
    redirect_to locations_path, notice: I18n.t('success.messages.deactivated', resource: 'Location')
  end

  def activate
    @location = current_resource
    @location.activate
    redirect_to locations_path, notice: I18n.t('success.messages.activated', resource: 'Location')
  end

  protected

  def locations
    @locations = Location.by_root
  end

  helper_method :locations

  private

  def set_location
    @location = LocationForm.new(current_resource)
  end

  def current_resource
    @current_resource ||= Location.includes(:labwares).find(params[:id]) if params[:id]
  end

  def permitted_params
    location_attrs =  Location.new.attributes.keys.map(&:to_sym)
    params.permit(:action, :controller, location: [*location_attrs,
                                                   :parent_id,
                                                   :user_code,
                                                   :start_from,
                                                   :end_to,
                                                   :reserve,
                                                   :coordinateable])
  end
end
