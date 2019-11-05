# frozen_string_literal: true

##
# Check whether the passed attribute for the record has a parent.
class NestedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.parent.valid?
      record.errors[attribute] << I18n.t("errors.messages.nested")
    end
  end
end
