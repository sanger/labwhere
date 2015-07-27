##
# Labware is stored in a location.
# LabWhere needs to know nothing about it apart from it's barcode and where it is.
class Labware < ActiveRecord::Base

  include SoftDeletable
  include Searchable::Client
  include AssertLocation
  include Auditable

  belongs_to :location
  belongs_to :coordinate

  validates :barcode, presence: true, uniqueness: true
  validates :location, nested: true, unless: Proc.new { |l| l.location.nil? || l.location.unknown? }

  removable_associations :location

  searchable_by :barcode

  scope :by_barcode, lambda{|barcodes| includes(:location).where(barcode: barcodes)}

  ##
  # find a Labware by its barcode
  def self.find_by_code(code)
    find_by(barcode: code)
  end

  def location
    super || coordinate.location
  end

  def coordinate
    super || NullCoordinate.new
  end

  def empty?
    false
  end

  ##
  # Useful for creating audit records. There are certain attributes which are not needed.
  def as_json(options = {})
    super({ except: [:location_id, :coordinate_id, :previous_location_id, :deleted_at]}.merge(options)).merge(uk_dates).merge("location" => location.barcode)
  end

end
