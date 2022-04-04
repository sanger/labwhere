# frozen_string_literal: true

##
# Check whether the association for a belongs to exists.
# looks for either an object or id.
class ExistenceValidator < ActiveModel::EachValidator
  ##
  # If the object is blank or the field with _id is blank add
  # an error to the attribute
  def validate_each(record, attribute, value)
    if value.blank? && record.send("#{attribute}_id".to_sym).blank?
      record.errors.add(attribute, I18n.t("errors.messages.existence"))
    end
  end
end
