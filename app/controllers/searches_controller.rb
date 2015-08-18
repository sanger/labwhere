class SearchesController < ApplicationController

  def create
    @search = Search.find_or_create_by(search_params)
    if @search.valid?
      redirect_to search_path(@search)
    else
      redirect_to root_path
    end
  end

  def show
    @search = current_resource
  end

private

  def current_resource
    @current_resource ||= Search.find(params[:id]) if params[:id]
  end
  
  def search_params
    params.require(:search).permit(:term)
  end
end
