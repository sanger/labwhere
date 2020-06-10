# frozen_string_literal: true

class UploadFileController < ApplicationController
  def new
    @upload_file = UploadFileForm.new
  end

  def create

  end
end
