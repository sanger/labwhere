class Location < ActiveRecord::Base

  include ActionView::Helpers::TextHelper

  belongs_to :location_type

  belongs_to :parent, class_name: "Location"
  has_many :children, class_name: "Location", foreign_key: "parent_id"

  has_many :labwares

  validates :name, presence: true

  validates :location_type, existence: true, unless: Proc.new { |l| l.unknown? }

  after_create :generate_barcode
  before_save :update_active

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :without, ->(location) { active.where.not(id: location.id) }

  def inactive?
    !active?
  end

  def parent
    super || NullLocation.new
  end

  def residents
    "Location " << if labwares.empty?
                    "is empty"
                  else
                    "has #{pluralize(labwares.length, 'piece')} of Labware"
                  end
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

  def update_active
    self.deactivated_at = Time.zone.now if active_changed?(from: true, to: false)
  end

end
