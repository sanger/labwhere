##
# Form object for the Location Type
class LocationTypeForm
  include Auditor

  set_attributes :name

  ##
  # We should only be able to destroy a location type if it has no locations.
  def before_destroy
    errors.add(:base, I18n.t("errors.messages.location_type_in_use")) if location_type.has_locations?
  end
  
end