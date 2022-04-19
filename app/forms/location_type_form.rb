# frozen_string_literal: true

##
# Form object for the Location Type
class LocationTypeForm
  include AuthenticationForm
  include Auditor

  set_attributes :name

  def destroy(params)
    form_variables.assign(self, params)
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
