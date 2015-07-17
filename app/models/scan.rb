##
# Scanning labware in and out of a location
# link between labware and locations and users.
class Scan < ActiveRecord::Base

  include AssertLocation

  enum status: [:in, :out]

  belongs_to :location
  belongs_to :user

  # before_save :update_labware_locations, :set_status
  before_save :set_status

  #TODO: previous location is a problem but seems to be the only way to create a decent message.
  def create_message(labwares)
    self.message = "#{labwares.count} labwares scanned #{self.status} " << if in?
      "to #{location.name}"
    else
      "from #{labwares.map(&:previous_location).compact.uniq.map(&:name).join(" ")}"
    end
  end

private

  def set_status
    self.status = Scan.statuses[:out] if self.location.unknown?
  end

end
