class LocationType < ActiveRecord::Base

  include Searchable::Client
  include AddAudit

  has_many :locations
  has_many :audits, as: :auditable

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  scope :ordered, -> { order(:name) }

  searchable_by :name

  def destroyable
    unless has_locations?
      yield if block_given?
    end
  end

  def has_locations?
    locations.present?
  end

end
