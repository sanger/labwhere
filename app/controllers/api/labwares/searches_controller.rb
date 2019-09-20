class Api::Labwares::SearchesController < ApiController

  def create
    render json: Labware.includes([{ location: [{ coordinates: [:labware, :location] }] }, :coordinate])
                        .by_barcode(params[:barcodes]), include: ["location.coordinates"]
  end

end