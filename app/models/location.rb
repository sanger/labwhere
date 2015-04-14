class Location < ActiveRecord::Base

  include ActionView::Helpers::TextHelper

  belongs_to :location_type

  belongs_to :parent, class_name: "Location"
  has_many :children, class_name: "Location", foreign_key: "parent_id"

  has_many :labwares

  validates :name, presence: true

  validates :location_type, existence: true

  after_create :generate_barcode

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :without, ->(location) { active.where.not(id: location.id) }

  accepts_nested_attributes_for :labwares, allow_destroy: true, reject_if: proc { |attributes| attributes['barcode'].blank? }

  def inactive?
    !active?
  end

  def parent
    super || NullLocation.new
  end

  # def parents(parents = [])
  #   parents.tap do |p|
  #     unless self.parent.nil?
  #       p << self.parent
  #       self.parent.parents(p)
  #     end
  #   end
  # end

  def residents
    "Location " << if labwares.empty?
                    "is empty"
                  else
                    "has #{pluralize(labwares.length, 'piece')} of Labware"
                  end
  end

private
  
  def generate_barcode
    self.barcode = "#{self.name}:#{self.id}"
    save
  end

end
