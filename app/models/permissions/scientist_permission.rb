# frozen_string_literal: true

##
# Permissions for a Scientist
# TODO: check below
# Allowed to:
# scan
# coordinates
# upload
# printers??
# teams??
module Permissions
  class ScientistPermission < BasePermission
    def initialize(user)
      super
      allow :scans, [:create]
      allow "api/scans", [:create]
      allow "api/coordinates", [:update]
      allow "api/locations/coordinates", [:update]
      allow :upload_labware, [:create]
    end
  end
end
