##
# Validates the location for a particular object:
# * If the location is nil and a location barcode is present this signifies the barcode is wrong.
# * If the location is present and it is not a container it is not valid
# * If the location is present and it is not active it is not valid
# * If the location is present and it does not have a parent then it is not valid.
class LocationValidator < ActiveModel::Validator
  def validate(record)
    unless record.location.nil? || record.location.unknown?
      record.errors.add(:location, I18n.t("errors.messages.container")) unless record.location.container?
      record.errors.add(:location, I18n.t("errors.messages.active")) unless record.location.active?
      NestedValidator.new({attributes: :location}).validate_each(record, :location, record.location)
    else
      record.errors.add(:location, I18n.t("errors.messages.existence")) if record.location_barcode.present?
    end
  end  
end