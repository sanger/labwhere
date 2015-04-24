class LocationType < ActiveRecord::Base

  include Searchable::Client

  has_many :locations

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  before_destroy :check_existing_locations

  scope :ordered, -> { order(:name) }

  searchable_by :name

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
