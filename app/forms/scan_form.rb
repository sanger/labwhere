class ScanForm

  include ActiveModel::Model

  delegate :location, to: :scan

  validates :location, nested: true, unless: Proc.new { |l| l.location.nil? } 

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
  
end