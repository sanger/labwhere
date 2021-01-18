# frozen_string_literal: true

require 'csv'

class LocationFinder
  include ActiveModel::Model

  attr_accessor :file

  def initialize(params = {})
    super(params)
    find_locations
  end

  def barcodes
    @barcodes ||= formatted_data
  end

  def formatted_data
    parsed = ::CSV.parse(file)
    parsed.flatten.compact.collect { |barcode| barcode.try(:strip) }
  end

  def results
    @results ||= {}
  end

  private

  def find_locations
    barcodes.each do |barcode|
      results[barcode] = Labware.includes(:location).find_by(barcode: barcode) || NullLabware.new
    end
  end

end
