##
# 
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

  #TODO: abstract previous location behaviour into appropriate place
  def self.previous_locations(labwares)
    Location.find(labwares.pluck(:previous_location_id).compact.uniq)
  end

  def self.build_for(object, labwares)
    case labwares
    when String
      build_by_barcodes(object, labwares)
    when Array 
      build_by_attributes(object, labwares)
    end
  end

  def self.find_by_code(code)
    find_by(barcode: code)
  end

  def coordinate
    super || NullCoordinate.new
  end

  class NullCoordinate
    def name
      "null"
    end
  end

private

  def update_previous_location
    self.previous_location_id = self.location_id_was if  self.location_id_changed?
  end

  def self.build_by_barcodes(object, barcodes)
    barcodes.split("\n").each do |barcode|
      object.labwares << find_or_initialize_by(barcode: barcode.remove_control_chars)
    end
  end

  def self.build_by_attributes(object, labwares)
    labwares.each do |labware|
      object.labwares << find_or_new_by_barcode_with_coordinates(labware)
    end
  end

  def self.find_or_new_by_barcode_with_coordinates(attributes)
    labware = find_or_initialize_by(barcode: attributes[:barcode])
    labware.coordinate = Coordinate.find_or_create_by_name(attributes[:coordinate])
    labware
  end

end
