# frozen_string_literal: true

require 'csv'

class LocationFinder
  include ActiveModel::Model

  validate :check_number_of_columns

  attr_accessor :file

  def data
    # we could have an empty file we have a validation for that
    # this removes the need for any expensive logic.
    @data ||= ::CSV.parse(file || "")
  end

  def barcodes
    @barcodes ||= formatted_data
  end

  # this is only a single column file so we can flatten it.
  # remove any blanks and duplicates
  # no need to error it as it a report
  def formatted_data
    data.flatten.compact.collect { |barcode| barcode.try(:strip) }
  end

  def results
    @results ||= {}
  end

  def run
    return unless valid?

    find_locations
  end

  private

  def find_locations
    barcodes.each do |barcode|
      results[barcode] = Labware.includes(:location).find_by(barcode: barcode) || NullLabware.new
    end
  end

  def check_number_of_columns
    # again we could have some expensive logic but this will cover empty files and multiple columns
    return if data.try(:first).try(:length) == 1

    errors.add(:base, 'There is something wrong with the file. There should only be 1 column with barcodes.')
  end
end
