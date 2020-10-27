# frozen_string_literal: true

require 'csv'

class ManifestUploader
  include ActiveModel::Model

  attr_accessor :file, :user

  validate :check_locations, :check_duplicate_positions, :check_positions_valid

  def data
    @data ||= ::CSV.parse(file).drop(1)
  end

  def run
    return false unless valid?

    ActiveRecord::Base.transaction do
      data.each do |row|
        location_barcode, labware_barcode, position = row
        labware = Labware.find_or_initialize_by(barcode: labware_barcode.strip)
        labware.location = locations[location_barcode.strip]
        labware.coordinate = stored_coordinates["#{location_barcode.strip}, #{position.strip}"] unless position.nil?
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

  def stored_coordinates
    @stored_coordinates ||= {}
  end

  def locations
    @locations ||= Location.where(barcode: location_barcodes)
                           .include_for_labware_receipt
                           .index_by(&:barcode)
  end

  def missing_locations
    @missing_locations ||= location_barcodes.reject { |barcode| locations.key?(barcode.strip) }
  end

  def ordered_location_barcodes
    @ordered_location_barcodes ||= location_barcodes.select { |barcode| locations[barcode.strip].type == "OrderedLocation" unless locations[barcode.strip].nil? }
  end

  def ordered_location_rows
    @ordered_location_rows ||= data.collect.with_index { |item, index| [(index + 1).to_s] + item if ordered_location_barcodes.include?(item.first.strip) }.compact
  end

  def check_locations
    return if missing_locations.empty?

    errors.add(:base, "location(s) with barcode #{missing_locations.join(',')} do not exist")
  end

  def check_duplicate_positions
    location_groups = ordered_location_rows.group_by{ |row| [row[1], row[3]]}.values.select{ |group| group.length>1}

    location_groups.each do |group|
      line_numbers = group.map{|row| row[0]}.join(',')
      errors.add(:base, "Line(s) #{line_numbers}: duplicate target positions") unless line_numbers.nil?
    end
  end

  def check_positions_valid
    ordered_location_rows.each do |row|
      line_index, location_barcode, labware_barcode, position = row.collect(&:strip)

      if position.nil?
        errors.add(:base, "Line #{line_index}: target position not defined for labware with barcode #{labware_barcode}")
      else
        coordinate = Coordinate.find_by(location_id: locations[location_barcode.strip].id, position: position)
        if coordinate.nil?
          errors.add(:base, "Line #{line_index}: target position #{position} for location with barcode #{location_barcode} does not exist")
        elsif coordinate.filled?
          errors.add(:base, "Line #{line_index}: target position #{position} for labware with barcode #{labware_barcode} is already occupied")
        else
          stored_coordinates["#{location_barcode.strip}, #{position.strip}"] = coordinate
        end
      end
    end
  end
end
