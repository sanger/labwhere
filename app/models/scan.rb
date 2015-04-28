class Scan < ActiveRecord::Base

  belongs_to :location
  has_many :events
  has_many :labwares, through: :events

  before_save :get_locations, :set_labware_locations
  after_save :update_location_counts

private

  def get_locations
    @locations_to_update = labwares.collect { |labware| labware.location}
  end

  def set_labware_locations
    labwares.each {|labware| labware.update(location: self.location)}
  end

  def update_location_counts
    @locations_to_update += [self.location, Location.unknown]
    @locations_to_update.compact.uniq.each do |location|
      location.update(labwares_count: location.labwares.count)
    end
  end



end
