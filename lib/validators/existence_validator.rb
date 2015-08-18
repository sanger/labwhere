##
# Check whether the association for a belongs to exists.
# looks for either an object or id.
class ExistenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank? && record.send("#{attribute}_id".to_sym).blank?
      record.errors[attribute] << I18n.t("errors.messages.existence")
    end
  end
end