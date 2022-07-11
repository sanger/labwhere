# frozen_string_literal: true

# EmptyParentValidator
class EmptyParentValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:parent, 'must be empty') if record.parent.present?
  end
end
