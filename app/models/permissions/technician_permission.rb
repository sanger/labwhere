# frozen_string_literal: true

##
# Permissions for a Technician
#
module Permissions
  class TechnicianPermission < ScientistPermission
    # - Technician's cannot edit Admin users or set users to admin type
    # - Technician's cannot edit the protect flag within Locations
    def initialize(user)
      super
      allow :move_locations, [:create]
      allow :location_types, [:create, :update]
      allow :teams, [:create, :update]
      allow :users, [:create, :update]
      allow :locations, [:create, :update] do |record|
        check_locations(record)
      end
    end

    private

    def check_locations(record)
      if record.location.protect || (record.action == "update" && (Location.find(record.location.id).protect != record.location.protect))
        record.errors.add(:base, "Technician's cannot create/edit protected locations")
        false
      else
        true
      end
    end
  end
end
