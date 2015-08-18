class Api::LabwaresController < ApiController

  def show
    render json: current_resource
  end

private

  def current_resource
    Labware.find_by_code(params[:barcode]) if params[:barcode]
  end

end