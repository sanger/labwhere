# frozen_string_literal: true

class Api::Labwares::AuditsController < ApiController
  def index
    render json: current_resource
  end

  private

  def current_resource
    Labware.find_by_code(params[:labware_barcode]).audits if params[:labware_barcode]
  end
end
