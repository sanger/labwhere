class Api::Labwares::SearchesController < ApiController

  def create
    render json: Labware.by_barcode(params[:barcodes])
  end

end