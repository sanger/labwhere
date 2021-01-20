# frozen_string_literal: true

##
# Permissions for a Technician
# TODO: check below
# Allowed to:
# check printers???
module Permissions
  class TechnicianPermission < ScientistPermission
    def initialize(user)
      super
      # The commented actions below are inherited from ScientistPermission
      # allow :scans, [:create]
      # allow :upload_labware, [:create]
      # allow "api/scans", [:create]
      # allow "api/coordinates", [:update]
      # allow "api/locations/coordinates", [:update]
      allow :move_locations, [:create]
      allow :empty_locations, [:create]
    end
  end
end
