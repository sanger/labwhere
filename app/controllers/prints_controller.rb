class PrintsController < ApplicationController

  layout false

  def new
    @location = current_resource
  end

  def create
    @print_barcode = LabelPrinter.new(printer: params[:printer_id], locations: location_ids, label_template_id: Rails.configuration.label_templates[params[:barcode_type]])
    @print_barcode.post
    redirect_to locations_path, notice: @print_barcode.message
  end

private

  def current_resource
    @current_resource ||= Location.find(params[:location_id]) if params[:location_id]
  end

  def location_ids
    params[:print_child_barcodes] ? location_resource.child_ids : params[:location_id]
  end

  def location_resource
    Location.find(params[:location_id])
  end
end
