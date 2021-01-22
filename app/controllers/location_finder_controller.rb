# frozen_string_literal: true

class LocationFinderController < ApplicationController
  def new
    @location_finder = LocationFinderForm.new
  end

  def create
    @location_finder = LocationFinderForm.new
    if @location_finder.submit(params)
      render :create
    else
      render :new
    end
  end
end
