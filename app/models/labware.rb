class Labware < ActiveRecord::Base
  belongs_to :location

  validates :barcode, presence: true, uniqueness: true
  validates :location, nested: true, unless: Proc.new { |l| l.location.nil? }

  def current_location
    if location
      location.barcode
    else
      "on bench/in lab/in processing"
    end
  end

end
