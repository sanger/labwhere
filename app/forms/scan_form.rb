# frozen_string_literal: true

##
# This will create a persisted scan.
# It can be used from a view or elsewhere.
class ScanForm
  include FormObject
  include AuthenticationForm
  include StorageValidator
  include Rails.application.routes.url_helpers

  add_form_variables :labware_barcodes, :location_barcode, :start_position, location: :find_location

  after_validate do
    scan.add_attributes_from_collection(LabwareCollection.open(location: location, user: current_user,
                                                               coordinates: available_coordinates,
                                                               labwares: labwares).push)
    scan.save
  end

  validate :check_available_coordinates, if: proc { |l| l.location.present? && l.location.ordered? }
  validate :check_if_any_barcodes_are_locations

  delegate :message, :created_at, :updated_at, to: :scan

  private

  def find_location
    Location.find_by_code(location_barcode)
  end

  def available_coordinates
    # if start_position is not provided, to_i converts '' to 0 - so it fills the location from the start
    @available_coordinates ||= location.available_coordinates(start_position.to_i, labwares.count)
  end

  def check_available_coordinates
    return if available_coordinates.count == labwares.count

    errors.add(:base, I18n.t('errors.messages.not_enough_empty_coordinates'))
  end

  def labwares
    @labwares ||= labware_barcodes.split("\n").uniq.collect(&:strip)
  end

  def check_if_any_barcodes_are_locations
    return unless labwares.any? { |labware| labware.match(/^#{Location::BARCODE_PREFIX}?/o) }

    errors.add(:base, I18n.t('errors.messages.not_labware', url: new_move_location_path))
  end
end
