class HistoriesController < ApplicationController

  before_action :histories, only: [:index]

  def index

  end

protected

  def histories
    @histories ||= Labware.find(params[:labware_id]).histories
  end

  helper_method :histories
end
