class Scan < ActiveRecord::Base

  belongs_to :location
  has_many :events
  has_many :labwares, through: :events

  before_save :add_labwares_locations

private

  def add_labwares_locations
    labwares.each { |labware| labware.update(location: self.location) }
  end

end
