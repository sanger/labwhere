class Event < ActiveRecord::Base
  belongs_to :scan
  belongs_to :labware
end
