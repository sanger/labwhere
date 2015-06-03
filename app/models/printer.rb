class Printer < ActiveRecord::Base

  validates_presence_of :name, :uuid
  validates_uniqueness_of :name

  has_many :audits, as: :auditable

  include AddAudit
end
