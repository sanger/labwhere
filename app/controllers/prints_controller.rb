class PrintsController < ApplicationController

  layout false

  def new
    @location = current_resource
  end

  def create
    label_template_id = Rails.configuration.label_templates[params[:barcode_type]]
    @print_barcode = LabelPrinter.new(printer: params[:printer_id],
                                      locations: location_ids,
                                      label_template_id: label_template_id,
                                      copies: params[:copies].to_i)
    @print_barcode.post

    respond_to do |format|
      msg = @print_barcode.message + message_suffix
      if @print_barcode.response_ok?
        flash[:notice] = msg
      else
        flash[:alert] = msg
      end
      format.js { render 'prints/print_update_view' }
    end
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

  def message_suffix
    suffix = params[:print_child_barcodes] ? " for each child of" : " for"
    suffix + " location: #{current_resource.name}"
  end
end
