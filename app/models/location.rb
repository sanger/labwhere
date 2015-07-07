##
# A location can store locations or labware
class Location < ActiveRecord::Base

  include Searchable::Client
  include HasActive
  include AddAudit

  belongs_to :location_type, counter_cache: true
  belongs_to :parent, class_name: "Location"
  has_many :children, class_name: "Location", foreign_key: "parent_id"
  has_many :audits, as: :auditable
  has_many :labwares

  validates :name, presence: true
  validates :location_type, existence: true, unless: Proc.new { |l| l.unknown? }
  validates_format_of :name, with: /\A[\w\-\s]+\z/
  validates_length_of :name, maximum: 50

  scope :without, ->(location) { active.where.not(id: location.id) }
  scope :without_unknown, ->{ where.not(id: Location.unknown.id) }

  before_save :synchronise_status_of_children
  before_save :set_parentage
  after_create :generate_barcode
  after_update :cascade_parentage

  searchable_by :name, :barcode

  ##
  # It is possible for the parent to be nil
  # This will ensure we don't get a no method error.
  def parent
    super || NullLocation.new
  end

  ##
  # When a labware is scanned out the location is unknown.
  # If a labware does not have a location it will be set to unknown.
  # This location is created when it is first queried.
  def self.unknown
    find_by(name: "UNKNOWN") || create(name: "UNKNOWN")
  end

  ##
  # Return a list of location names separated by a delimiter
  def self.names(locations, spacer = " ")
    locations.map(&:name).join(spacer)
  end

  ##
  # Find a location by its barcode.
  def self.find_by_code(code)
    find_by(barcode: code)
  end

  ##
  # For a given set of locations reset the number of labwares.
  def self.reset_labwares_count(locations)
    locations.each do |location|
      location.update_column(:labwares_count, location.labwares.count)
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

  ##
  # Follows the null object pattern.
  class NullLocation
    def name; "Empty" end

    def barcode; "Empty" end

    def parent; nil end

    def valid?; false end

    def empty?; true end
    
  end

  ##
  # Useful for creating audit records. There are certain attributes which are not needed.
  def as_json(options = {})
    super({ except: [:audits_count, :labwares_count, :deactivated_at]}.merge(options)).merge(uk_dates)
  end

  ##
  # If the status of a location changes we need to ensure that all of its children are synchonised.
  # For example if a location is deactivated then all of its children need to be.
  def synchronise_status_of_children
    if status_changed?
      inactive? ? deactivate_children : activate_children
    end
  end

  ##
  # Deactivate the child location as well of all of its childrens' children
  def deactivate_children
    children.each do |child|
      child.deactivate 
      child.deactivate_children
    end
  end

  ##
  # Activate the child location as well of all of its childrens' children
  def activate_children
    children.each do |child|
      child.activate 
      child.activate_children
    end
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

  ##
  # Ensure that the parentage attribute stays current.
  # If the parent changes then we need to ensure that all of its childrens parentage is updated.
  def cascade_parentage
    children.each do |child|
      child.update_attribute(:parentage, child.set_parentage)
    end
  end

private
  
  ##
  # The barcode is the name downcased with spaces replaced by dashes with the id added again separated by a space.
  def generate_barcode
    update_column(:barcode, "#{self.name.gsub(' ','-').downcase}-#{self.id}")
  end

end
