# frozen_string_literal: true

#
# A coordinate is a defined position in a location which can hold a piece of labware.
# A location will usually have a fixed set of coordinates.
class Coordinate < ApplicationRecord
  include Auditable

  belongs_to :location
  has_one :labware, autosave: true

  validates :position, :row, :column, presence: true, numericality: true
  validates :location, existence: true
  validates :location, nested: true, unless: proc { |l| l.location.nil? || l.location.unknown? }

  scope :ordered, -> { order(position: :asc) }

  def self.find_by_position(attributes)
    find_by(attributes)
  end

  def self.filled
    all.select(&:filled?)
  end

  # Check if the coordinate has a piece of labware
  def filled?
    !vacant?
  end

  # Check if the coordinate can be filled with a piece of labware
  def vacant?
    labware.empty?
  end

  # If the labware is empty return a null labware object
  def labware
    super || NullLabware.new
  end

  # Fill the coordinate with a piece of labware
  def fill(labw)
    update(labware: labw)
    labw
  end
end
