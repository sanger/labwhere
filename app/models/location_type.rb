##
# Every location must have a type.
class LocationType < ActiveRecord::Base

  include Searchable::Client
  include Auditable

  has_many :locations

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  scope :ordered, -> { order(:name) }

  searchable_by :name

  before_destroy :check_locations

  #TODO: Buildings and Sites need to be dealt with differently to ensure more flexible code
  def self.building
    find_by_name("Building")
  end

  def self.building?(location_type)
    location_type == building
  end

  def self.not_building?(location_type)
    location_type != building
  end

   def self.site
    find_by_name("Site")
  end

  def self.site?(location_type)
    location_type == site
  end

  def self.not_site?(location_type)
    location_type != site
  end



  ##
  # A location type can only be destroyed if it has no locations
  def destroyable
    unless has_locations?
      yield if block_given?
    end
  end

  ##
  # Has the location type got any locations attached.
  def has_locations?
    locations.present?
  end

  ##
  # We dont need the count for the audit record.
  def as_json(options = {})
    super(options).merge(uk_dates)
  end

private

  def check_locations
    if has_locations?
      errors.add(:base, I18n.t("errors.messages.location_type_in_use"))
      false
    end
  end

end
