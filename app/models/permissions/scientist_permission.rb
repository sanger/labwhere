# frozen_string_literal: true

##
# Permissions for a Scientist
#
module Permissions
  class ScientistPermission < BasePermission
    def initialize(user)
      super
      allow :scans, [:create]
      # Check if Scientists should be able to upload labware
      allow :upload_labware, [:create]
      allow "api/scans", [:create]
      allow "api/coordinates", [:update]
      allow "api/locations/coordinates", [:update]
    end
  end
end
