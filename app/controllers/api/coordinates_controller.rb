# frozen_string_literal: true

class Api::CoordinatesController < ApiController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def update
    coordinates_form = CoordinatesForm.new

    if coordinates_form.submit(params)
      render json: coordinates_form.coordinates
    else
      render json: { errors: coordinates_form.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def record_not_found(error)
    render json: { errors: error.message }, status: :unprocessable_entity
  end
end
