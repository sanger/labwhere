class Labware < ActiveRecord::Base

  include SoftDeletable
  include Searchable::Client
  include AssertLocation

  belongs_to :location
  belongs_to :previous_location, class_name: "Location"
  has_many :histories
  has_many :scans, through: :histories

  validates :barcode, presence: true, uniqueness: true
  validates :location, nested: true, unless: Proc.new { |l| l.location.nil? || l.location.unknown? }

  removable_associations :location

  searchable_by :barcode

  before_save :update_previous_location

  def self.previous_locations(labwares)
    Location.find(labwares.pluck(:previous_location_id).compact.uniq)
  end

  def self.update_previous_location_counts(labwares)
    previous_locations(labwares).map(&:save)
  end

private

  def update_previous_location
    self.previous_location_id = self.location_id_was if  self.location_id_changed?
  end

end
