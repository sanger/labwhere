class ScanForm

  include ActiveModel::Model

  attr_accessor :location_barcode, :labware_barcodes
  attr_reader :scan_processor

  delegate :errors, to: :scan_processor

  def persisted?
    false
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Scan")
  end

  def initialize
    @scan_processor = ScanProcessor.new(scan)
  end

  def submit(params)
    @scan_processor = ScanProcessor.new(scan, params)
    @scan_processor.save
  end

  def scan
    @scan ||= Scan.new
  end

end