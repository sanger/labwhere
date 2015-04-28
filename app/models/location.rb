class Location < ActiveRecord::Base

  include Searchable::Client

  enum status: [:active, :inactive]

  belongs_to :location_type, counter_cache: true

  belongs_to :parent, class_name: "Location"
  has_many :children, class_name: "Location", foreign_key: "parent_id"

  has_many :labwares

  validates :name, presence: true

  validates :location_type, existence: true, unless: Proc.new { |l| l.unknown? }

  after_create :generate_barcode
  before_save :update_status

  scope :without, ->(location) { active.where.not(id: location.id) }
  scope :without_unknown, ->{ without(Location.unknown)}

  searchable_by :name, :barcode

  def parent
    super || NullLocation.new
  end

  def self.unknown
    find_by(name: "UNKNOWN") || create(name: "UNKNOWN")
  end

  def unknown?
    name == "UNKNOWN" 
  end

private
  
  def generate_barcode
    update(barcode: "#{self.name}:#{self.id}")
  end

  def update_status
    self.deactivated_at = Time.zone.now if status_changed?(from: "active", to: "inactive")
  end

end
