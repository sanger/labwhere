# frozen_string_literal: true

require 'csv'

# ManifestUploader - allows manifest of labwares to be added to a Location
class ManifestUploader
  include ActiveModel::Model

  attr_accessor :json, :user_code, :controller, :action, :current_user

  validate :check_labwares_present, :check_locations, :check_for_ordered_locations,
           :check_for_missing_or_invalid_data, :check_if_any_labwares_are_locations,
           :check_user

  MIMIMUM_CELL_LENGTH = 5

  def data
    @data ||= formatted_data
  end

  # json = { labwares: [{location_barcode: '', labware_barcode: '' }] }
  # @return [[ "lw-location-1-2", "RNA000001" ], [ "lw-location-1-2", "RNA000002" ]]
  def formatted_data
    return [] unless json[:labwares]

    json[:labwares].map { |elem| [elem[:location_barcode], elem[:labware_barcode]] } || []
  end

  def labwares
    @labwares ||= data.collect(&:second).uniq
  end

  def run
    return false unless valid?

    ActiveRecord::Base.transaction do
      data.each do |row|
        location_barcode, labware_barcode = row
        labware = Labware.find_or_initialize_by(barcode: labware_barcode)
        labware.location = locations[location_barcode]
        labware.save!
        labware.create_audit!(current_user, AuditAction::MANIFEST_UPLOAD)
      end
    end
    true
  rescue StandardError => e
    errors.add(:base, e.message)
    false
  end

  def location_barcodes
    @location_barcodes ||= data.collect(&:first).uniq
  end

  def locations
    @locations ||= Location.where(barcode: location_barcodes)
                           .include_for_labware_receipt
                           .index_by(&:barcode)
  end

  def missing_locations
    @missing_locations ||= location_barcodes.reject { |barcode| locations.key?(barcode) }
  end

  def check_locations
    return if missing_locations.empty?

    errors.add(:base, "location(s) with barcode '#{missing_locations.join(',')}' do not exist")
  end

  # If a location has coordinates it will cause all sorts of problems and should fail
  # otherwise it will cause all sorts of problems downstream
  def check_for_ordered_locations
    ordered_locations = locations.select { |_k, v| v.ordered? }
    return if ordered_locations.empty?

    errors.add(:base, "You are trying to put stuff into #{ordered_locations.keys.join(',')} which is the wrong type")
  end

  # Agreement come to by the customer in that if any of the cells are blank or
  # if the length of the string is less than 5 then it is an error.
  # 5 is an aribitrary number which could be changed if we find it is too lax.
  def check_for_missing_or_invalid_data
    data.each do |row|
      break unless row.each do |cell|
        next unless cell.blank? || cell.length < MIMIMUM_CELL_LENGTH

        errors.add(:base,
                   'It looks like there is some missing or invalid data. Please review and ' \
                   "remove anything that shouldn't be there.")
        break
      end
    end
  end

  def check_if_any_labwares_are_locations
    return if errors.present?

    return unless labwares.any? { |labware| labware.match(/^#{Location::BARCODE_PREFIX}?/o) }

    errors.add(:base,
               'Labware barcodes cannot be the same as an existing location barcode. ' \
               'Please review and remove incorrect labware barcodes')
  end

  def check_user
    @current_user = User.find_by_code(user_code)
    UserValidator.new.validate(self)
  end

  def check_labwares_present
    return if errors.present?

    errors.add(:base, 'No labwares have been provided') if json[:labwares].blank?
  end
end
