class ScanForm

  include ActiveModel::Model

  attr_accessor :location_barcode, :labware_barcodes

  delegate :location, to: :scan

  validate :check_for_errors

  def persisted?
    false
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Scan")
  end

  def submit(params)
    scan.location = Location.find_by(barcode: params["location_barcode"])

    if valid?
      scan.labwares << build_labwares(params["labware_barcodes"])
      scan.save
      true
    else
      false
    end
  end

  def scan
    @scan ||= Scan.new
  end

private

  def build_labwares(barcodes)
    [].tap do |labwares|
      barcodes.split("\n").each do |barcode|
        labware = Labware.find_or_initialize_by(barcode: barcode)
        labware.location = scan.location
        labware.save
        labwares << labware
      end
    end
  end

  def check_for_errors
    unless scan.valid?
      scan.errors.each do |key, value|
        errors.add key, value
      end
    end
  end
  
end