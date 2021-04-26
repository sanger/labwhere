# frozen_string_literal: true

class UploadLabwareController < ApplicationController
  def new
    @upload_labware = UploadLabwareForm.new
  end

  def create
    @upload_labware = UploadLabwareForm.new

    Broker::Handle.create_connection
    
    if @upload_labware.submit(params)
      redirect_to new_upload_labware_path, notice: "Labware successfully uploaded."
    else
      render :new
    end
  end
end
