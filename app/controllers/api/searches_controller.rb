# frozen_string_literal: true

# Api::SearchesController
class Api::SearchesController < ApiController
  def create
    @search = Search.find_or_create_by(search_params)
    if @search.valid?
      render json: @search.results
    else
      render json: @search.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def search_params
    params.expect(search: [:term])
  end
end
