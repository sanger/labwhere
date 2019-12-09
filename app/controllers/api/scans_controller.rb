# frozen_string_literal: true

class Api::ScansController < ApiController
  def create
    @scan = ScanForm.new
    if @scan.submit(params)
      render json: @scan, serializer: ScanSerializer
    else
      render json: { errors: @scan.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
