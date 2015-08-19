#
# A coordinate is a defined position in a location which can hold a piece of labware.
# A location will usually have a fixed set of coordinates.
class Coordinate < ActiveRecord::Base
  belongs_to :location
  has_one :labware, autosave: true

  validates :position, :row, :column, presence: true, numericality: true
  validates :location, existence: true
  validates :location, nested: true, unless: Proc.new { |l| l.location.nil? || l.location.unknown? }

  scope :ordered, -> { order(position: :asc) }

  def self.find_by_position(attributes)
    find_by(attributes)
  end

  # Check if the coordinate has a piece of labware
  def filled?
    !empty?
  end

  # Check if the coordinate can be filled with a peice of labware
  def empty?
    labware.empty?
  end

  # If the labware is empty return a null labware object
  def labware
    super || NullLabware.new
  end

  # Fill the coordinate with a piece of labware
  def fill(l)
    update_attribute(:labware, l)
    l
  end

end