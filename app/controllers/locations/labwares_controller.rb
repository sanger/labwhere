# frozen_string_literal: true

class Locations::LabwaresController < ApplicationController
  before_action :labwares, only: [:index]

  def index
  end

  protected

  def labwares
    @labwares ||= Location.find(params[:location_id]).labwares
  end

  helper_method :labwares
end
