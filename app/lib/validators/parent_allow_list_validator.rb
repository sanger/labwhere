# frozen_string_literal: true

class ParentAllowListValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:parent,"must be one of the following types: #{options[:location_types].map(&:name).join(', ')}") unless record.parent.present? && record.parent.location_type.in?(options[:location_types])
  end
end
