##
# Printers which are used to reprint barcodes.
# The name of the printers are needed to use the printing service.
class Printer < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name

  include Auditable

  ##
  # Ensure that the correct attributes are returned for the audit record.
  def as_json(options = {})
    super(options).merge(uk_dates)
  end
end
