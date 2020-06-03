# frozen_string_literal: true

##
# Permissions for a Standard User
# Allowed to create a scan in the user interface and the api.
module Permissions
  class ScientistPermission < BasePermission
    def initialize(user)
      super
      allow :scans, [:create]
      allow "api/scans", [:create]
      allow "api/coordinates", [:update]
      allow "api/locations/coordinates", [:update]
      allow :location_scans, [:create]
    end
  end
end
