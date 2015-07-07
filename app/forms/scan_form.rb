##
# This will create a persisted scan.
# It can be used from a view or elsewhere.
class ScanForm

  include ActiveModel::Model
  include ActiveModel::Serialization
  include HashAttributes

  attr_reader :scan, :controller, :action, :current_user, :labwares
  attr_accessor :location_barcode, :labware_barcodes, :user_code
  delegate :location, :message, :created_at, :updated_at, to: :scan

  validate :check_for_errors, :check_user

  ##
  # A scan will never be edited.
  def persisted?
    false
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Scan")
  end

  def initialize
  end

  ##
  # When a scan form is submitted the user and location are added
  # from the passed attributes.
  # If they are valid then the labwares are added to the scan and it
  # is saved.
  def submit(params)
    set_params_attributes(:scan, params)
    @current_user = User.find_by_code(user_code)
    scan.location = Location.find_by_code(location_barcode)
    scan.user = current_user
    if valid?
      Labware.build_for(scan, labwares || labware_barcodes)
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