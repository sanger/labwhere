class Scan < ActiveRecord::Base

  belongs_to :location
  has_many :histories
  has_many :labwares, through: :histories

  before_save :get_labware_locations, :set_labware_locations
  after_save :update_location_counts

  def location_name
    (location || NullLocation.new).name
  end

#TODO: These methods can be improved for performance and succinctness. Maybe a concern for general counter caching? Maybe use the last scan?
private

  def get_labware_locations
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
