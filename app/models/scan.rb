##
# Scanning labware in and out of a location
# A scan is a throwaway object i.e. it has no use once it has been done.
# A scan will have any number of Labwares attached but these are not permanently linked.
# We know we are scanning in or out by whether there is a location.
# We need to show a message to the user showing how many pieces of labwares were scanned in or out
# of the location. For this purpose we create a temporary list of all the labwares
# so we can determine which locations they have come from and how many there are.
class Scan < ActiveRecord::Base
  include AssertLocation

  enum status: [:in, :out]

  belongs_to :location, optional: true
  belongs_to :user, optional: true

  before_save :set_status, :create_message

  attr_writer :labwares

  # If we are scanning in tell the user how many labwares have been scanned in to the scan location.
  # If we are scanning out tell the user how many labwares have been scanned out of their previous locations.
  def create_message
    self.message = "#{labwares.count} labwares scanned #{self.status} " << if in?
                                                                             "to #{location.name}"
                                                                           else
                                                                             "from #{labwares.original_location_names}"
                                                                           end
  end

  def labwares
    @labwares ||= NullLabwareCollection.new
  end

  def add_attributes_from_collection(labware_collection)
    self.location = labware_collection.location
    self.user = labware_collection.user
    self.labwares = labware_collection
    self.start_position = labware_collection.start_position
  end

  private

  def set_status
    self.status = Scan.statuses[:out] if self.location.unknown?
  end
end
