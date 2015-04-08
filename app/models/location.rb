class Location < ActiveRecord::Base
  belongs_to :location_type

  belongs_to :parent, class_name: "Location"
  has_many :children, class_name: "Location", foreign_key: "parent_id"

  validates :name, presence: true

  validates :location_type, existence: true

  after_create :generate_barcode

  def parents(parents = [])
    parents.tap do |p|
      unless self.parent.nil?
        p << self.parent
        self.parent.parents(p)
      end
    end
  end

private
  
  def generate_barcode
    self.barcode = "#{self.name}:#{self.id}"
    save
  end
end
