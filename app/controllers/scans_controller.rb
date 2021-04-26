# frozen_string_literal: true

class ScansController < ApplicationController
  def new
    @scan = ScanForm.new
  end

  def create
    @scan = ScanForm.new

    Broker::Handle.create_connection

    if @scan.submit(params)
      redirect_to root_path, notice: @scan.message
    else
      render :new
    end
  end
end
