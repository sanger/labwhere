##
# This will create a persisted scan.
# It can be used from a view or elsewhere.
# 
class ScanForm

  include ActiveModel::Model
  include HashAttributes

  attr_reader :scan, :controller, :action, :user
  attr_accessor :location_barcode, :labware_barcodes, :user_code
  delegate :location, :message, to: :scan

  validate :check_for_errors, :check_user

  def persisted?
    false
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Scan")
  end

  def initialize
  end

  def submit(params)
    set_params_attributes(:scan, params)
    @user = User.find_by_code(user_code)
    scan.location = Location.find_by(barcode: location_barcode)
    scan.user = user
    if valid?
      Labware.build_for(scan, labware_barcodes)
      scan.save
    else
      false
    end
  end

  def scan
    @scan ||= Scan.new
  end

private

  def check_for_errors
    LocationValidator.new.validate(self)
  end

  def check_user
    UserValidator.new.validate(self)
  end
  
end