class Api::HistoriesController < ApiController

  def index
    render json: current_resource
  end

private

  def current_resource
    Labware.find_by_code(params[:labware_barcode]).histories if params[:labware_barcode]
  end

end
