##
# Scanning labware in and out of a location
# A scan is a throwaway object i.e. it has no use once it has been done.
# A scan will have any number of Labwares attached but these are not permanently linked.
# We know we are scanning in or out be whether there is a location.
# We need to show a message to the user showing how many pieces of labwares were scanned in or out
# of the location. For this purpose we create a temporary list of all the labwares
# so we can determine which locations they have come from and how many there are.
class Scan < ActiveRecord::Base

  include AssertLocation

  enum status: [:in, :out]

  belongs_to :location
  belongs_to :user

  before_save :set_status, :create_message

  # Add a labware to a temporary object
  def add_labware(labware)
    labwares.add(labware) if labware
  end

  # If we are scanning in tell the user how many labwares have been scanned in to the scan location.
  # If we are scanning out tell the user how many labwares have been scanned out of their previous locations.
  def create_message
    self.message = "#{labwares.count} labwares scanned #{self.status} " << if in?
      "to #{location.name}"
    else
      "from #{labwares.unique_location_names}"
    end
  end

private

  def set_status
    self.status = Scan.statuses[:out] if self.location.unknown?
  end

  def labwares
    @labwares ||= Labwares.new
  end

  class Labwares

    attr_reader :count, :location_names

    def initialize
      @count = 0
      @location_names = []
    end

    def add(labware)
      @count += 1
      @location_names << labware.location.name
    end

    def unique_location_names
      location_names.uniq.join(", ")
    end
  end

end
