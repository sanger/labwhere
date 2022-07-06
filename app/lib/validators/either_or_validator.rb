# frozen_string_literal: true

##
# For two fields will check whether either one is completed
# These fields are signified by the options[:fields] attribute
class EitherOrValidator < ActiveModel::Validator
  # Check all of the fields signified by options
  # If all of them are empty add an error to the record
  def validate(record)
    fields = options[:fields]
    return unless fields.all? { |field| record.send(field).blank? }

    record.errors.add(:base, "#{fields.collect { |field| field.to_s.humanize }.join(' or ')} must be completed")
  end
end
