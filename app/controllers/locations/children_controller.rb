class Locations::ChildrenController < ApplicationController
  before_action :children, only: [:index]

  def index

  end

protected

  def children
    @children ||= Location.find(params[:location_id]).children
  end

  helper_method :children
  
end