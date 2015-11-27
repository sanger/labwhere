##
# Form object for the Location Type
class LocationTypeForm
  include AuthenticationForm
  include AddAudit

  set_attributes :name

  def destroy(params)
    self.form_variables.assign_top_level(self, params)
    return false unless valid?
    location_type.destroy
    return true if location_type.destroyed?
    add_errors
    false
  end
  
end