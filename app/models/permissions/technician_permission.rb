# frozen_string_literal: true

##
# Permissions for a Technician
#
module Permissions
  class TechnicianPermission < ScientistPermission
    def initialize(user)
      super
      allow :move_locations, [:create]
      allow :empty_locations, [:create]
    end
  end
end
