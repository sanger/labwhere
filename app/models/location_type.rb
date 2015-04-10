class LocationType < ActiveRecord::Base

  has_many :locations

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  before_destroy :check_existing_locations

private

  def check_existing_locations
    unless locations.empty?
      errors.add(:base, "Can't delete a location type which is being used for a location.")
      false
    else
      true
    end
  end
end
