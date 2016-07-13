##
# This will create a persisted scan.
# It can be used from a view or elsewhere.
class ScanForm

  include FormObject
  include AuthenticationForm

  set_form_variables :labwares, :labware_barcodes, :location_barcode, location: :find_location

  after_validate do
    scan.add_attributes_from_collection(LabwareCollection.new(location, current_user, _labwares).push)
    scan.save
  end

  validate :check_location, :check_reservation

  delegate :message, :created_at, :updated_at, to: :scan

private

  def find_location
    Location.find_by_code(location_barcode)
  end

  def check_location
    LocationValidator.new.validate(self)
  end

  def check_reservation
    barcodes = _labwares.instance_of?(String) ? _labwares.split("\n") : _labwares

    barcodes.each do |barcode|
      labware = Labware.find_or_initialize_by_barcode(barcode)
      next if labware.location.empty?
      check_location_for_reservation(labware.location)
    end
  end

  # Check through all ancestors to make sure none are reserved
  def check_location_for_reservation(location)
    if location.reserved? && location.reserved_by != current_user.team
      errors.add(:location, I18n.t("errors.messages.reserved", team: location.reserved_by.name))
      return
    end
    check_location_for_reservation(location.parent) if location.parent_id?
  end

  def _labwares
    labwares || labware_barcodes
  end

end