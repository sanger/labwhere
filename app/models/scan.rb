class Scan < ActiveRecord::Base
  belongs_to :location
  has_many :events
  has_many :labwares, through: :events

  validates_with LocationValidator, unless: Proc.new { |scan| scan.location.nil? }
end
