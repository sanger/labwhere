##
# Every location must have a type.
class LocationType < ActiveRecord::Base

  include Searchable::Client
  include AddAudit

  has_many :locations
  has_many :audits, as: :auditable

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  scope :ordered, -> { order(:name) }

  searchable_by :name

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
    super({ except: [:audits_count, :locations_count]}.merge(options)).merge(uk_dates)
  end

end
