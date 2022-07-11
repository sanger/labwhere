# frozen_string_literal: true

##
# Check whether the passed attribute for the record has a parent.
class NestedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.internal_parent.nil? # We use internal parent here to allow eager loading

    record.errors.add(attribute, I18n.t('errors.messages.nested'))
  end
end
