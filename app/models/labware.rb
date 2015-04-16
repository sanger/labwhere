class Labware < ActiveRecord::Base
  belongs_to :location
  has_many :events
  has_many :scans, through: :events

  validates :barcode, presence: true, uniqueness: true
  validates :location, nested: true, unless: Proc.new { |l| l.location.nil? || l.location.unknown? }

  before_save :assert_location

  include SoftDeletable

  removable_associations :location

private

  def assert_location
    self.location = Location.unknown if location.nil?
  end

end
