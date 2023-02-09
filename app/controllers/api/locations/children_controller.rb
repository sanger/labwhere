# frozen_string_literal: true

# Api::Locations::ChildrenController
class Api::Locations::ChildrenController < ApiController
  def index
    render json: current_resource
  end

  private

  def current_resource
    Location.find_by_code(params[:location_barcode]).children if params[:location_barcode]
  end
end
