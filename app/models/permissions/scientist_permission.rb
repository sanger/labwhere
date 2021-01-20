# frozen_string_literal: true

##
# Permissions for a Scientist
#
module Permissions
  class ScientistPermission < BasePermission
    def initialize(user)
      super
      allow :scans, [:create]
      allow :upload_labware, [:create]
      # Below is used from Sequencescape labware reception
      allow "api/scans", [:create]
      allow "api/coordinates", [:update]
      allow "api/locations/coordinates", [:update]
    end
  end
end
