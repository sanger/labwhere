# frozen_string_literal: true

# LabwaresController
class LabwaresController < ApplicationController
  def show
    @labware = current_resource
  end

  private

  def current_resource
    @current_resource ||= Labware.find(params[:id]) if params[:id]
  end
end
