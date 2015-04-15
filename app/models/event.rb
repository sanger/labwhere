class Event < ActiveRecord::Base
  belongs_to :labware
  belongs_to :location

  validates :labware, existence: true
  validates :location, existence: true
end
