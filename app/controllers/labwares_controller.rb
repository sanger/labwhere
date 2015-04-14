class LabwaresController < ApplicationController

  before_action :labwares, only: [:index]

  def index

  end

protected

  def labwares
    @labwares ||= Labware.all
  end

  helper_method :labwares
  
end