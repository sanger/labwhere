##
# Teams which users belong to.
class Team < ActiveRecord::Base

  include AddAudit

  validates :number, presence: true, uniqueness: true, numericality: true
  validates :name, presence: true, uniqueness: {case_sensitive: false}

  has_many :audits, as: :auditable

  def as_json(options = {})
    super({ except: [:audits_count]}.merge(options)).merge(uk_dates)
  end
  
end
