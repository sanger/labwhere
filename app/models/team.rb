class Team < ActiveRecord::Base

  include AddAudit

  validates :number, presence: true, uniqueness: true, numericality: true
  validates :name, presence: true, uniqueness: {case_sensitive: false}

  has_many :audits, as: :auditable

  
end
