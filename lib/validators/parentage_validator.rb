class ParentageValidator < ActiveModel::Validator
  def validate(record)
    unless record.parents.uniq.length == record.parents.length
      record.errors[:base] << I18n.t("errors.messages.parentage")
    end
  end

end