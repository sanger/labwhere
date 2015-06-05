##
# Printers which are used to reprint barcodes.
# The name and uuid of printers are needed to use the printing service.
class Printer < ActiveRecord::Base

  validates_presence_of :name, :uuid
  validates_uniqueness_of :name

  has_many :audits, as: :auditable

  include AddAudit
end
