# frozen_string_literal: true

##
# Printers which are used to reprint barcodes.
# The name of the printers are needed to use the printing service.
class Printer < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true

  include Auditable

  ##
  # Ensure that the correct attributes are returned for the audit record.
  def as_json(options = {})
    super(options).merge(uk_dates)
  end
end
