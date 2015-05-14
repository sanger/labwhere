class UserValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:user, I18n.t("errors.messages.existence")) if record.current_user.guest?
    record.errors.add(:user, I18n.t("errors.messages.authorised")) unless record.current_user.allow?(record.controller, record.action)
  end  
end