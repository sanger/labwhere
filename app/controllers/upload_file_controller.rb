# frozen_string_literal: true

class UploadFileController < ApplicationController
  def new
    @upload_file = UploadFileForm.new
  end

  def create
    @upload_file = UploadFileForm.new
    if @upload_file.submit(params)
      redirect_to new_upload_file_path, notice: "File successfully uploaded."
    else
      render :new
    end
  end
end
