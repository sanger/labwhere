# frozen_string_literal: true

class PrintsController < ApplicationController
  layout false

  def new
    @location = current_resource
  end

  def create
    label_template_name = Rails.configuration.label_templates[params[:barcode_type]]
    @print_barcode = LabelPrinter.new(printer: params[:printer_id],
                                      locations: location_ids,
                                      label_template_name: label_template_name,
                                      copies: params[:copies].to_i)
    @print_barcode.post

    respond_to do |format|
      @message = @print_barcode.message + message_suffix
      if @print_barcode.response_ok?
        @message_type = 'notice'
      else
        @message_type = 'alert'
      end
      format.js { render 'prints/create' }
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
