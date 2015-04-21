class LocationValidator < ActiveModel::Validator
  def validate(record)
    unless record.location.nil?
      record.errors.add(:location, I18n.t("errors.messages.container")) unless record.location.container?
      record.errors.add(:location, I18n.t("errors.messages.active")) unless record.location.active?
      NestedValidator.new({attributes: :location}).validate_each(record, :location, record.location)
    else
      record.errors.add(:location, I18n.t("errors.messages.existence")) if record.location_barcode.present?
    end
  end  
end