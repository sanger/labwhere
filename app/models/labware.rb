class Labware < ActiveRecord::Base

  include SoftDeletable
  include Searchable::Client

  belongs_to :location
  has_many :histories
  has_many :scans, through: :histories

  validates :barcode, presence: true, uniqueness: true
  validates :location, nested: true, unless: Proc.new { |l| l.location.nil? || l.location.unknown? }

  before_save :assert_location

  removable_associations :location

  searchable_by :barcode

private

  def assert_location
    self.location = Location.unknown if location.nil?
  end

end
