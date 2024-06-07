# frozen_string_literal: true

namespace :destroyed_location do
  desc 'Creates Destroyed Location Type and Location'
  task create: :environment do |_t|
    location_type_name = 'Destroyed'
    location_name = 'Destroyed'
    location_barcode = 'lw-destroyed'
    parent_name = 'Sanger'
    parent_type = 'Site'

    ActiveRecord::Base.transaction do
      # The destroyed location needs a parent to be able to scan labware.
      # We assume that a parent location with the name 'Sanger' and the
      # location type name 'Site' already exists.
      parent = UnorderedLocation
               .joins(:location_type)
               .find_by(name: parent_name, location_types: { name: parent_type })

      # Create the Destroyed Location Type.
      location_type = LocationType.find_or_create_by!(name: location_type_name)

      # Create the Destroyed Location.
      UnorderedLocation.create_with(
        barcode: location_barcode,
        location_type: location_type,
        parent: parent
      ).find_or_create_by(name: location_name)
    end
  end
end
