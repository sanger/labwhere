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
      errors.add(:base, I18n.t("errors.messages.location_type_in_use"))
      false
    else
      true
    end
  end
end
