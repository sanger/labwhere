class Labware < ActiveRecord::Base

  include SoftDeletable
  include Searchable::Client
  include AssertLocation

  belongs_to :location
  has_many :histories
  has_many :scans, through: :histories

  validates :barcode, presence: true, uniqueness: true
  validates :location, nested: true, unless: Proc.new { |l| l.location.nil? || l.location.unknown? }

  removable_associations :location

  searchable_by :barcode

  def self.locations(labwares)
    labwares.collect { |labware| labware.location}.compact.uniq
  end

  def self.previous_locations(labwares)
    labwares.collect { |labware| labware.previous_location}.compact.uniq
  end

  def self.update_previous_location_counts(labwares)
    previous_locations(labwares).map(&:save)
  end

  def previous_location
    at = scans.count-2
    at < 0 ? nil : scans.at(at-2).location
  end

end
