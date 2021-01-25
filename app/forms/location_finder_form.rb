# frozen_string_literal: true

class LocationFinderForm
  include ActiveModel::Model

  attr_reader :params, :file, :location_finder

  delegate :csv, to: :location_finder

  validate :check_required_params, :check_file_format, :check_location_finder

  def submit(params)
    @params = params
    assign_params

    # we could have an emtpty file.
    # the alternative would be to validate prior to this but then
    # we would have to validate again.
    @location_finder = LocationFinder.new(file: file.try(:tempfile))

    return false unless valid?

    location_finder.run
    true
  end

  def form_sym
    :location_finder_form
  end

  def assign_params
    @file = params[:location_finder_form][:file]
  end

  private

  def check_file_format
    CsvFileValidator.new.validate(self)
  end

  def check_required_params
    params.require(:location_finder_form).permit([:file]).tap do |form_params|
      form_params.require([:file])
    end
  rescue ActionController::ParameterMissing
    errors.add(:base, 'The required fields must be filled in')
  end

  def check_location_finder
    return if location_finder.valid?

    location_finder.errors.full_messages.each do |error|
      errors.add(:base, error)
    end
  end
end
