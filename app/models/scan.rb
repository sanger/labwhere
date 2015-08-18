##
# Scanning labware in and out of a location
# link between labware and locations and users.
class Scan < ActiveRecord::Base

  include AssertLocation

  enum status: [:in, :out]

  belongs_to :location
  belongs_to :user

  before_save :set_status, :create_message

  def add_labware(labware)
    labwares.add(labware) if labware
  end

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
