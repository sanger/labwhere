# frozen_string_literal: true

# EmptyLocationsController
class EmptyLocationsController < ApplicationController
  def new
    @empty_location = EmptyLocationForm.new
  end

  def create
    @empty_location = EmptyLocationForm.new
    if @empty_location.submit(params)
      redirect_to new_empty_location_path, notice: I18n.t('success.messages.emptied', resource: 'Location')
    else
      render :new
    end
  end
end
