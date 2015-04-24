#TODO: This may need some mild refactoring to ensure that attributes are not set twice.
class ScanProcessor

  include ActiveModel::Validations

  include HashAttributes

  attr_reader :scan, :location_barcode, :labware_barcodes
  delegate :location, to: :scan

  validate :check_for_errors

  def initialize(scan, params = {})
    @scan = scan
    set_attributes(params)
    scan.location = Location.find_by(barcode: location_barcode)
  end

  def save
    if valid?
      build_labwares
      scan.save
    else
      false
    end
  end

private

  def build_labwares
    labware_barcodes.split("\n").each do |barcode|
      scan.labwares << Labware.find_or_initialize_by(barcode: barcode.remove_control_chars)
    end
  end

  def check_for_errors
    LocationValidator.new.validate(self)
  end
  
end