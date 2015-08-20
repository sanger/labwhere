##
# A location can store locations or labware
class Location < ActiveRecord::Base

  include Searchable::Client
  include HasActive
  include Auditable

  belongs_to :location_type
  belongs_to :parent, class_name: "Location"
  has_many :labwares

  validates :name, presence: true
  validates :location_type, existence: true, unless: Proc.new { |l| l.unknown? }
  validates_format_of :name, with: /\A[\w\-\s]+\z/
  validates_length_of :name, maximum: 50

  scope :without, ->(location) { active.where.not(id: location.id) }
  scope :without_unknown, ->{ where.not(id: Location.unknown.id) }
  scope :ordered, -> { where(type: "OrderedLocation")}
  scope :unordered, -> { where(type: "UnorderedLocation")}

  before_save :set_parentage
  after_create :generate_barcode

  searchable_by :name, :barcode

  ##
  # It is possible for the parent to be nil
  # This will ensure we don't get a no method error.
  def parent
    super || NullLocation.new
  end

  ##
  # Follows the Null object pattern.
  # We only want to add a Null Location Type if the record is persisted
  # otherwise we get ActiveRecord errors and it will bypass validation.
  def location_type
    if new_record?
      super
    else
      super || NullLocationType.new
    end
  end

  ##
  # When a labware is scanned out the location is unknown.
  # If a labware does not have a location it will be set to unknown.
  # This location is created when it is first queried.
  def self.unknown
    find_by(name: "UNKNOWN") || create(name: "UNKNOWN")
  end

  ##
  # Find a location by its barcode.
  def self.find_by_code(code)
    if code.present?
      find_by(barcode: code)
    else
      unknown
    end
  end

  ##
  # Check if the location is unknown.
  def unknown?
    name == "UNKNOWN" 
  end

  ##
  # Part of location validation is to check whether it is an empty location.
  def empty?
    false
  end

  # A location will only need coordinates if it has rows and columns
  def coordinateable?
    rows > 0 && columns > 0
  end

  # Is it an unordered location?
  def unordered?
    type ==  "UnorderedLocation"
  end

  # Is it an ordered location?
  def ordered?
    type == "OrderedLocation"
  end

  # This will transform the location into the correct type of location based on whether it
  # has coordinates.
  def transform
    if coordinateable?
      self.type = "OrderedLocation"
      self.becomes(OrderedLocation)
    else
      self.type = "UnorderedLocation"
      self.becomes(UnorderedLocation)
    end
  end

  def type
    super || "Location"
  end

  ##
  # Useful for creating audit records. There are certain attributes which are not needed.
  def as_json(options = {})
    super({ except: [:deactivated_at, :location_type_id]}.merge(options)).merge(uk_dates).merge("location_type" => location_type.name)
  end

  def children
    []
  end

  def coordinates
    []
  end

  ##
  # The parentage field is a text representation of all the names of a locations parents.
  # Useful for querying purposes.
  # This will iterate through the parentage adding the name to a string until the parent is empty.
  def set_parentage
    current = parent
    [].tap do |p|
      until current.empty?
        p.unshift(current.name)
        current = current.parent
      end
      self.parentage = p.join(" / ")
    end
  end

  # Add a piece of Labware to the location.
  # Find or initialize it first.
  # Returns the labware and a copy of it before the location is updated
  def add_labware(barcode)
    labware = Labware.find_or_initialize_by(barcode: barcode)
    labware_dup = labware.dup
    labware.flush_coordinate
    labwares << labware
    [labware, labware_dup]
  end

  # Add several pieces of Labware only if the barcodes passed are a string
  # Split the barcodes by returns and add each one.
  # In some cases we need to do stuff with each labware before and after it has changed.
  # in which case we allow a block to be executed on each piece of labware that is added.
  def add_labwares(barcodes)
    return unless barcodes.instance_of?(String)
    barcodes.split("\n").each do |barcode| 
      after, before = add_labware(barcode.remove_control_chars)
      yield(after, before) if block_given?
    end
  end

  # Find any locations within the location which have enough contiguous available coordinates
  # signified by n.
  def available_coordinates(n)
    []
  end

private
  
  ##
  # The barcode is the name downcased with spaces replaced by dashes with the id added again separated by a space.
  def generate_barcode
    update_column(:barcode, "lw-#{self.name.gsub(' ','-').downcase}-#{self.id}")
  end

end
