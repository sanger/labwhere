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
      allow :move_locations, [:create] do |record|
        check_locations(record)
        # Users cannot move a protected location
      end
      allow :empty_locations, [:create]
      allow :users, [:update] do |record|
        record.user.id == user.id && record.user.type == user.type
        # Users can update themselves but not change their types
      end
      allow "api/scans", [:create]
      allow "api/coordinates", [:update]
      allow "api/locations/coordinates", [:update]
    end

    private

    def check_locations(record)
      protected_locations = record.child_locations.select(&:protect?)
      if protected_locations.blank?
        true
      else
        record.errors.add(:base, "Location with barcode #{protected_locations.map(&:barcode).join(', ')} #{I18n.t('errors.messages.protected')}")
        false
      end
    end
  end
end
