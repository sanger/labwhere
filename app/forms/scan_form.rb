##
# This will create a persisted scan.
# It can be used from a view or elsewhere.
class ScanForm

  include FormObject
  include AuthenticationForm

  set_form_variables :labwares, :labware_barcodes, :location_barcode, location: :find_location

  after_validate do 
    scan.add_attributes_from_collection(LabwareCollection.new(location, current_user, labwares || labware_barcodes).push)
    scan.save
  end

  validate :check_location

  delegate :message, :created_at, :updated_at, to: :scan

private

  def find_location
    Location.find_by_code(location_barcode)
  end

  def check_location
    LocationValidator.new.validate(self)
  end

end