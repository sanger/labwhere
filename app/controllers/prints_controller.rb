class PrintsController < ApplicationController

  layout false

  def new
    @location = current_resource
  end

  def create
    @print_barcode = LabelPrinter.new(params[:printer_id], params[:location_id])
    @print_barcode.post
    redirect_to locations_path, notice: @print_barcode.message
  end

private

  def current_resource
    @current_resource ||= Location.find(params[:location_id]) if params[:location_id]
  end
end
