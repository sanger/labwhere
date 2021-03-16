# frozen_string_literal: true

##
# Permissions for a Technician
#
module Permissions
  class TechnicianPermission < ScientistPermission
    # Has same permissions as admins except some indepedent validations such as:
    # - Technician's cannot edit Admin users or set users to admin type
    # - Technician's cannot edit the protect flag within Locations
    def initialize(user)
      super
      allow_all
    end
  end
end
