# frozen_string_literal: true

##
# Labware is stored in a location.
# LabWhere needs to know nothing about it apart from its barcode and where it is.
# If a labware has no location it's location will be set to unknown automatically
class Labware < ActiveRecord::Base
  include SoftDeletable
  include Searchable::Client
  include Auditable
  include Uuidable

  belongs_to :location
  belongs_to :coordinate

  validates :barcode, presence: true, uniqueness: true

  with_options unless: -> { location.nil? || location.unspecified? } do
    validates :location, nested: true
  end

  removable_associations :location

  searchable_by :barcode

  scope :by_barcode, lambda { |barcodes| includes(:location).where(barcode: barcodes) }
  scope :by_barcode_known_locations, lambda { |barcodes|
                                       includes(:location)
                                         .where(barcode: barcodes)
                                         .where.not(location_id: UnknownLocation.get)
                                     }

  ##
  # find a Labware by its barcode
  def self.find_by_code(code)
    find_by(barcode: code)
  end

  def self.find_or_initialize_by_barcode(object)
    barcode = object.kind_of?(Hash) ? object[:barcode] : object
    Labware.find_or_initialize_by(barcode: barcode.remove_control_chars)
  end

  def location
    super || coordinate.location
  end

  def full_path
    @full_path ||= location.path.pluck(:name).join(' > ')
  end

  def coordinate
    super || NullCoordinate.new
  end

  def empty?
    false
  end

  def exists
    "Yes"
  end

  def flush_coordinate
    assign_attributes(coordinate: nil)
    self
  end

  def flush_location
    assign_attributes(location: nil)
    self
  end

  def flush
    flush_coordinate
    flush_location
    self
  end

  ##
  # Useful for creating audit records. There are certain attributes which are not needed.
  def as_json(options = {})
    super({ except: [:location_id, :coordinate_id, :previous_location_id, :deleted_at] }.merge(options)).merge(uk_dates).merge("location" => location.barcode)
  end

  def write_event(audit_record)
    e = Event.new(labware: self, audit: audit_record)
    Messages.publish(e)
  end
end
