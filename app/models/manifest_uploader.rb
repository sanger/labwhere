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
        location_barcode, labware_barcode = row
        labware = Labware.find_or_initialize_by(barcode: labware_barcode.strip)
        labware.location = locations[location_barcode.strip]
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
    @location_barcodes ||= data.collect { |item| item.first.strip }.uniq
  end

  def locations
    @locations ||= Location.where(barcode: location_barcodes)
                           .include_for_labware_receipt
                           .index_by(&:barcode)
  end

  def missing_locations
    @missing_locations ||= location_barcodes.reject { |barcode| locations.key?(barcode.strip) }
  end

  def check_locations
    return if missing_locations.empty?

    errors.add(:base, "location(s) with barcode #{missing_locations.join(',')} do not exist")
  end
end
