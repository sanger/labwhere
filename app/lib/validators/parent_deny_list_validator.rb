# frozen_string_literal: true

class ParentDenyListValidator < ActiveModel::Validator
  def validate(record)
    return unless record.parent.present? && record.parent.location_type.in?(options[:location_types])

    record.errors.add(:parent,
                      "can not be any of the following types: #{options[:location_types].map(&:name).join(', ')}")
  end
end
