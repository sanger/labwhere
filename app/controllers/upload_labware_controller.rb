# frozen_string_literal: true

class UploadLabwareController < ApplicationController
  def new
    @upload_labware = UploadLabwareForm.new
  end

  def create
    @upload_labware = UploadLabwareForm.new

    if @upload_labware.submit(params)
      redirect_to new_upload_labware_path, notice: I18n.t('success.messages.uploaded', resource: 'Labware')
    else
      render :new
    end
  end
end
