# frozen_string_literal: true

##
# Permissions for a Technician
#
module Permissions
  class TechnicianPermission < ScientistPermission
    # - Technician's cannot edit Admin users or set users to admin type
    # - Technician's cannot edit the protected flag within Locations or create protected locations
    def initialize(user)
      super
      allow :move_locations, [:create]
      allow :location_types, [:create, :update]
      allow :teams, [:create, :update]
      allow :users, [:create, :update] do |record|
        !record.user.administrator? && !record.user.instance_of?(Administrator)
        # instance_of?(Administrator) checks the user being edited isnt an Administrator
        # .administrator? checks the type of the user isnt being set as Administrator
      end
      allow :locations, [:create, :update] do |record|
        !record.location.protected_changed?
      end
    end
  end
end
