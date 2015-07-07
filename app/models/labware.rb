##
# Labware is stored in a location.
# LabWhere needs to know nothing about it apart from it's barcode and where it is.
class Labware < ActiveRecord::Base

  include SoftDeletable
  include Searchable::Client
  include AssertLocation

  belongs_to :location
  belongs_to :previous_location, class_name: "Location"
  belongs_to :coordinate
  has_many :histories
  has_many :scans, through: :histories

  validates :barcode, presence: true, uniqueness: true
  validates :location, nested: true, unless: Proc.new { |l| l.location.nil? || l.location.unknown? }

  removable_associations :location

  searchable_by :barcode

  before_save :update_previous_location

  scope :by_barcode, lambda{|barcodes| includes(:location).where(barcode: barcodes)}

  # Return a unique list of the previous locations for Labwares
  def self.previous_locations(labwares)
    Location.find(labwares.pluck(:previous_location_id).compact.uniq)
  end

  ##
  # Add labwares to the passed object.
  # Labwares can either be a string of labware barcodes
  # or an array of hashes containing barcodes and coordinates.
  # If the labware already exists it will be returned otherwise it will be created.
  # If a coordinate is passed it will either be found or created.
  # This will only build the labwares not save them.
  def self.build_for(object, labwares)
    case labwares
    when String
      build_by_barcodes(object, labwares)
    when Array 
      build_by_attributes(object, labwares)
    end
  end

  ##
  # find a Labware by its barcode
  def self.find_by_code(code)
    find_by(barcode: code)
  end

  ##
  # Ensure that nil coordinate is never returned.
  # Return a Null Object if no coordinate exists
  def coordinate
    super || NullCoordinate.new
  end

  ##
  # This class is useful for preventing nil method errors.
  # If a piece of Labware has no coordinate return null
  class NullCoordinate
    def name
      "null"
    end
  end

private
  
  ##
  # If a Labwares location has changed update the previous location
  def update_previous_location
    self.previous_location_id = self.location_id_was if  self.location_id_changed?
  end

  ##
  # For a string of barcodes separated by a return.
  # Add a list of labwares to the passed object.
  # If it exists find it if not build a new one.
  def self.build_by_barcodes(object, barcodes)
    barcodes.split("\n").each do |barcode|
      object.labwares << find_or_initialize_by(barcode: barcode.remove_control_chars)
    end
  end

  ##
  # For a hash of labwares add them to the passed object.
  # For each one if it exists find it otherwise build it.
  def self.build_by_attributes(object, labwares)
    labwares.each do |labware|
      object.labwares << find_or_new_by_barcode_with_coordinates(labware)
    end
  end

  ##
  # Find or initialize a Labware by its barcode.
  # If the coordinate exists return the object otherwise create it.
  def self.find_or_new_by_barcode_with_coordinates(attributes)
    labware = find_or_initialize_by(barcode: attributes[:barcode])
    labware.coordinate = Coordinate.find_or_create_by_name(attributes[:coordinate])
    labware
  end

end
