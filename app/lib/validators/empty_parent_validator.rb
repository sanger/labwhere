# frozen_string_literal: true

class EmptyParentValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:parent] << "must be empty" if record.parent.present?
  end
end
