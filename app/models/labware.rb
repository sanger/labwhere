class Labware < ActiveRecord::Base
  belongs_to :location

  validates :barcode, presence: true, uniqueness: true
  validates :location, nested: true, unless: Proc.new { |l| l.location.nil? || l.location.unknown? }

  include SoftDeletable

  removable_associations :location

end
