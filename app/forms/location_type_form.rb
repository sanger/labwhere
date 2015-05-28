class LocationTypeForm
  include Auditor

  set_attributes :name

  def before_destroy
    errors.add(:base, I18n.t("errors.messages.location_type_in_use")) if location_type.has_locations?
  end
  
end