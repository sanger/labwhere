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
      allow :users, [:create, :update] do |record|
        check_user(record)
      end
      allow :locations, [:create, :update] do |record|
        check_locations(record)
      end
    end

    private

    def check_user(record)
      # If user type is creating an admin or is editing an admin then error
      if record.user.type == "Administrator" || record.user.instance_of?(Administrator)
        record.errors.add(:base, "Technician's cannot create/edit admin users")
        false
      else
        true
      end
    end

    def check_locations(record)
      # If location is protected or if user is updating a protected location then error
      if record.location.protect || (record.action == "update" && Location.find(record.location.id).protect)
        record.errors.add(:base, "Technician's cannot create/edit protected locations")
        false
      else
        true
      end
    end
  end
end
