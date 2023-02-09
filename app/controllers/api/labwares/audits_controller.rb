# frozen_string_literal: true

# Api::Labwares::AuditsController
class Api::Labwares::AuditsController < ApiController
  def index
    render json: current_resource
  end

  private

  def current_resource
    Labware.find_by_barcode(params[:labware_barcode]).audits if params[:labware_barcode]
  end
end
