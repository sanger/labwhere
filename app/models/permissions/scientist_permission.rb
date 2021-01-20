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
      allow :upload_labware, [:create]
      # TODO: check if api is needed and by what
      allow "api/scans", [:create]
      allow "api/coordinates", [:update]
      allow "api/locations/coordinates", [:update]
    end
  end
end
