# frozen_string_literal: true

##
# Form object for updating a single Coordinate
class CoordinateForm
  include AuthenticationForm
  include StorageValidator
  include Auditor

  validate :labware_barcode_is_provided

  create_attributes :labware
  add_form_variables :labware_barcode, :location_barcode, location: :find_location, labware: :find_labware

  after_validate do
    coordinate.labware = find_labware
  end

  private

  def labware_barcode_is_provided
    errors.add(:base, 'A labware barcode must be provided') unless params.require(:coordinate).key?(:labware_barcode)
  end

  def find_labware
    @labware ||= Labware.find_or_create_by!(barcode: labware_barcode) unless labware_barcode.nil?
  end

  def find_location
    Location.find_by_code(location_barcode)
  end

  def labwares
    [labware_barcode]
  end
end
