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

  #TODO: abstract previous location behaviour into appropriate place
  def self.previous_locations(labwares)
    Location.find(labwares.pluck(:previous_location_id).compact.uniq)
  end

  def self.update_previous_location_counts(labwares)
    previous_locations(labwares).map(&:save)
  end

  def self.build_for(object, barcodes)
     barcodes.split("\n").each do |barcode|
      object.labwares << find_or_initialize_by(barcode: barcode.remove_control_chars)
    end
  end

  def self.find_by_code(code)
    find_by(barcode: code)
  end

private

  def update_previous_location
    self.previous_location_id = self.location_id_was if  self.location_id_changed?
  end

end
