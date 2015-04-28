class Scan < ActiveRecord::Base

  belongs_to :location
  has_many :events
  has_many :labwares, through: :events

end
