# frozen_string_literal: true

##
# Permissions for a Technician
#
module Permissions
  class TechnicianPermission < ScientistPermission
    def initialize(user)
      super
      allow_all
    end
  end
end
