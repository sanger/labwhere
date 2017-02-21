##
# This will create a persisted scan.
# It can be used from a view or elsewhere.
class ScanForm

  include FormObject
  include AuthenticationForm

  set_form_variables :labware_barcodes, :location_barcode, :start_position, location: :find_location

  after_validate do
    scan.add_attributes_from_collection(LabwareCollection.open(location: location, user: current_user, coordinates: available_coordinates, labwares: labware_barcodes).push)
    scan.save
  end

  validate :check_location, :check_reservation
  validate :check_available_coordinates, if: proc { |l| l.start_position.present? && l.location.present? }

  delegate :message, :created_at, :updated_at, to: :scan

private

  def find_location
    Location.find_by_code(location_barcode)
  end

  def check_location
    LocationValidator.new.validate(self)
  end

  def check_reservation
    labwares.each do |barcode|
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

  def available_coordinates
    @available_coordinates ||= location.available_coordinates(start_position.to_i, labwares.count)
  end

  def check_available_coordinates
    unless available_coordinates.count == labwares.count
      errors.add(:base, I18n.t("errors.messages.not_enough_empty_coordinates"))
    end
  end

  def labwares
    @labwares ||= labware_barcodes.split("\n")
  end

end