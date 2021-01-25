# frozen_string_literal: true

class LocationFinderController < ApplicationController
  def new
    @location_finder = LocationFinderForm.new
  end

  def create
    @location_finder = LocationFinderForm.new
    if @location_finder.submit(params)
      send_data @location_finder.csv,
                type: 'text/csv; charset=utf-8; header=present',
                disposition: 'attachment; filename=locations.csv'
    else
      render :new
    end
  end
end
