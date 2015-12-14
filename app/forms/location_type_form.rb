##
# Form object for the Location Type
class LocationTypeForm
  include AuthenticationForm
  include Auditor

  set_attributes :name

  def destroy(params)
    self.form_variables.assign(self, params)
    return false unless valid?
    location_type.destroy
    if location_type.destroyed?
      true
    else
      add_errors
      false
    end
  end
  
end