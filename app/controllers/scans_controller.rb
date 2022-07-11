# frozen_string_literal: true

# ScansController
class ScansController < ApplicationController
  def new
    @scan = ScanForm.new
  end

  def create
    @scan = ScanForm.new

    if @scan.submit(params)
      redirect_to root_path, notice: @scan.message
    else
      render :new
    end
  end
end
