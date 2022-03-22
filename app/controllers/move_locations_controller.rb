# frozen_string_literal: true

class MoveLocationsController < ApplicationController
  def new
    @move_locations = MoveLocationForm.new
  end

  def create
    @move_locations = MoveLocationForm.new
    if @move_locations.submit(params)
      redirect_to new_move_location_path, notice: I18n.t('success.messages.moved', resource: 'Locations')
    else
      render :new
    end
  end
end
