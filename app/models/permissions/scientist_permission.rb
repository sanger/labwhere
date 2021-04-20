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
      allow :move_locations, [:create]
      allow :empty_locations, [:create]
      allow :users, [:update] do |record|
        user.id == record.user.id && record.user.scientist?
        # Scientists can update themselves but not change their types
      end
      allow "api/scans", [:create]
      allow "api/coordinates", [:update]
      allow "api/locations/coordinates", [:update]
    end
  end
end
