##
# A location can store locations or labware
class Location < ActiveRecord::Base

  UNKNOWN = "UNKNOWN"

  include Searchable::Client
  include HasActive
  include Auditable
  include SubclassChecker
  include Reservable

  belongs_to :location_type, optional: true # Optional for UnknownLocation
  belongs_to :team, optional: true
  belongs_to :internal_parent, class_name: "Location", optional: true
  has_many :coordinates
  has_many :labwares

  validates :name, presence: true, uniqueness: { scope: :ancestry, case_sensitive: true }

  validates_format_of :name, with: /\A[\w\-\s\(\)]+\z/
  validates_length_of :name, maximum: 60

  with_options unless: :unknown? do
    validates :location_type, existence: true
    validates_format_of :name, without: /UNKNOWN/i

    before_validation do
      apply_restrictions
    end
  end

  validates_with ContainerReservationValidator

  scope :without_location, -> (location) { active.where.not(id: location.id).order(id: :desc) }
  scope :without_unknown, -> { where.not(name: UNKNOWN) }
  scope :by_root, -> { without_unknown.roots }

  before_save :set_parentage
  before_save :set_internal_parent_id
  after_create :generate_barcode
  before_destroy :has_been_used

  searchable_by :name, :barcode
  has_subclasses :ordered, :unordered, :unknown, suffix: true

  # See https://github.com/stefankroes/ancestry
  has_ancestry counter_cache: true

  alias_method :has_child_locations?, :has_children?

  ##
  # It is possible for the parent to be nil
  # This will ensure we don't get a no method error.
  def parent
    super || NullLocation.new
  end

  def unknown?
    false
  end

  def children=(child_locations)
    child_locations.each do |child_location|
      child_location.parent = self
      child_location.save
    end
    reload
  end

  def unspecified?
    unknown?
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
  # Find a location by its barcode.
  def self.find_by_code(code)
    if code.present?
      find_by(barcode: code)
    else
      UnknownLocation.get
    end
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

  def destroyable
    unless used?
      yield if block_given?
    end
  end

  # This will transform the location into the correct type of location based on whether it
  # has coordinates.
  def transform
    self.becomes!(coordinateable? ? OrderedLocation : UnorderedLocation)
  end

  def type
    super || "Location"
  end

  ##
  # Useful for creating audit records. There are certain attributes which are not needed.
  def as_json(options = {})
    super({except: [:deactivated_at, :location_type_id]}.merge(options)).merge(uk_dates).merge("location_type" => location_type.name)
  end

  def child_count
    @child_count ||= (children_count + labwares.count)
  end

  def children_count
    super.nil? ? 0 : super
  end

  def coordinates
    []
  end

  def set_parentage
    self.parentage = ancestors.pluck(:name).join(" / ")
  end

  def set_internal_parent_id
    self.internal_parent_id = parent_id
  end

  # Dummy method
  def available_coordinates(_start, _number)
    []
  end

  private

  ##
  # The barcode is the name downcased with spaces replaced by dashes with the id added again separated by a space.
  def generate_barcode
    update_column(:barcode, "lw-#{self.name.gsub(' ', '-').downcase}-#{self.id}")
  end

  def apply_restrictions
    return unless location_type
    location_type.restrictions.each do |restriction|
      validates_with restriction.validator, restriction.params
    end
  end

  def used?
    child_count > 0 || audits.present?
  end

  def has_been_used
    return unless used?
    errors.add :location, "Has been used"
    throw :abort
  end
end
