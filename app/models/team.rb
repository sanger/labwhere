# frozen_string_literal: true

##
# Teams which users belong to.
class Team < ApplicationRecord
  include Auditable

  validates :number, presence: true, uniqueness: true, numericality: true
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :locations

  ##
  # Needed for the audit record.
  def as_json(options = {})
    super.merge(uk_dates)
  end
end
