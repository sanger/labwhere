class Coordinate < ActiveRecord::Base
  belongs_to :location
  has_one :labware, autosave: true

  validates :position, :row, :column, presence: true, numericality: true
  validates :location, existence: true
  validates :location, nested: true, unless: Proc.new { |l| l.location.nil? || l.location.unknown? }

  def self.find_by_position(attributes)
    find_by(attributes)
  end

  def filled?
    !labware.empty?
  end

  def empty?
    false
  end

  def labware
    super || NullLabware.new
  end

  #??? why does it not set the labware_id
  def fill(l)
    update_attribute(:labware, l)
    update_attribute(:labware_id, l.id)
    l
  end
end