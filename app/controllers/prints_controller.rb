class PrintsController < ApplicationController

  def new
    @location = current_resource
    respond_to do |format|
      format.js
    end
  end

  def create
    @print_barcode = LabelPrinter.new(params[:printer_id], params[:location_id])
    @print_barcode.post
    respond_to do |format|
      flash_keep @print_barcode.message
      format.js { render js: "window.location.pathname='#{locations_path}'" }
    end
  end

private

  def current_resource
    @current_resource ||= Location.find(params[:location_id]) if params[:location_id]
  end
end
