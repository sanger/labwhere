# frozen_string_literal: true

require 'csv'

class ManifestUploader
  include ActiveModel::Model

  attr_accessor :file, :user

  validate :check_locations

  def data
    @data ||= ::CSV.parse(file).drop(1)
  end

  def run
    return false unless valid?

    ActiveRecord::Base.transaction do
      data.each do |row|
        labware = Labware.find_or_initialize_by(barcode: row[1])
        labware.location = locations[row[0]]
        labware.save!
        labware.create_audit!(user, Audit::MANIFEST_UPLOAD_ACTION)
      end
    end
    true
  rescue StandardError => e
    errors.add(:base, e.message)
    false
  end

  def location_barcodes
    @location_barcodes ||= data.collect { |item| item.take(1) }.flatten.uniq
  end

  def locations
    @locations ||= {}.tap do |h|
      location_barcodes.each do |barcode|
        h[barcode] = Location.find_by(barcode: barcode)
      end
    end
  end

  def empty_locations
    @empty_locations ||= locations.select { |_k, v| v.nil? }
  end

  def check_locations
    return if empty_locations.empty?

    errors.add(:base, "location(s) with barcode #{empty_locations.keys.join(',')} do not exist")
  end
end
