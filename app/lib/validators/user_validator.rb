# frozen_string_literal: true

##
# Validates the user for a record.
# * If the current user is guest i.e. nil it is not valid.
# * If the current user is inactive it is not valid.
# * Check whether the current user is allowed to carry out the requested action.
class UserValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:user, I18n.t("errors.messages.existence")) if record.current_user.guest?
    record.errors.add(:user, I18n.t("errors.messages.active")) if record.current_user.inactive?
    record.errors.add(:user, I18n.t("errors.messages.authorised")) unless record.current_user.allow?(record.controller, record.action, record)
  end
end
