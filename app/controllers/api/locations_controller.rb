# frozen_string_literal: true

class Api::LocationsController < ApiController
  before_action :permitted_params, only: [:create, :update]

  def index
    render json: Location.by_root
  end

  def show
    render json: current_resource
  end

  def create
    @location = LocationForm.new
    process_location(@location.submit(permitted_params))
  end

  def update
    @location = LocationForm.new(current_resource)
    process_location(@location.update(permitted_params))
  end

  private

  def current_resource
    Location.find_by_code(params[:barcode]) if params[:barcode]
  end

  def process_location(succeeded)
    if succeeded
      render json: @location, serializer: "#{@location.type}Serializer".constantize
    else
      render json: { errors: @location.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def permitted_params
    location_attrs = Location.new.attributes.keys.map { |k| k.to_sym }
    params.permit(:action, :controller, location: [*location_attrs,
                                                   :parent_id,
                                                   :user_code,
                                                   :start_from,
                                                   :end_to,
                                                   :reserve,
                                                   :coordinateable])
  end
end
