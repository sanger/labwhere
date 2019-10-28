##
# Teams which users belong to.
class Team < ActiveRecord::Base
  include Auditable

  validates :number, presence: true, uniqueness: true, numericality: true
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :locations

  ##
  # Needed for the audit record.
  def as_json(options = {})
    super(options).merge(uk_dates)
  end
end
