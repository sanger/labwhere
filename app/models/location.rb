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

  after_create :generate_barcode
  before_save :update_labwares_count

  scope :without, ->(location) { active.where.not(id: location.id) }
  scope :without_unknown, ->{ where.not(id: Location.unknown.id) }

  searchable_by :name, :barcode

  def parent
    super || NullLocation.new
  end

  def self.unknown
    find_by(name: "UNKNOWN") || create(name: "UNKNOWN")
  end

  def self.names(locations, spacer = " ")
    locations.map(&:name).join(spacer)
  end

  def self.find_by_code(code)
    find_by(barcode: code)
  end

  def unknown?
    name == "UNKNOWN" 
  end

  def update_labwares_count
    self.labwares_count = labwares.count
  end

  class NullLocation
    def name; "Empty" end

    def barcode; "Empty" end

    def parent; nil end

    def valid?; false end

    def empty?; true end
    
  end

private
  
  def generate_barcode
    update_attribute :barcode, "#{self.name}:#{self.id}"
  end

end
