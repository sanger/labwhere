##
# This will create a persisted scan.
# It can be used from a view or elsewhere.
class ScanForm

  include ActiveModel::Model
  include ActiveModel::Serialization
  include HashAttributes

  attr_reader :scan, :controller, :action, :current_user, :labwares, :location
  attr_accessor :location_barcode, :labware_barcodes, :user_code
  delegate :message, :created_at, :updated_at, to: :scan

  validate :check_for_errors, :check_user

  # include FormObject
  # include AuthenticationForm

  # set_form_variables :labwares, :labware_barcodes, location: :find_location

  # after_validate do 
  #   scan.add_attributes_from_collection(LabwareCollection.new(location, current_user, labwares || labware_barcodes).push)
  #   scan.save
  # end

  # validate :check_location

  # delegate :message, :created_at, :updated_at, to: :scan

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
    @location = Location.find_by_code(location_barcode)
    if valid?
      scan.add_attributes_from_collection(LabwareCollection.new(location, current_user, labwares || labware_barcodes).push)
      scan.save
    else
      false
    end
  end

  def scan
    @scan ||= Scan.new
  end

private

  # def find_location(location)
  #   Location.find_by_code(location)
  # end

  # def check_location
  #   LocationValidator.new.validate(self)
  # end

  def check_for_errors
    LocationValidator.new.validate(self)
  end

  def check_user
    UserValidator.new.validate(self)
  end

end