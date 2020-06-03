# frozen_string_literal: true

class LocationScansController < ApplicationController
  def new
    @location_scan = LocationScanForm.new
  end

  def create
    @location_scan = LocationScanForm.new
    if @location_scan.submit(params)
      redirect_to new_location_scan_path, notice: "Locations successfully moved."
    else
      render :new
    end
  end
end
