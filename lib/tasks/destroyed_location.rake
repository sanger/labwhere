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
      # Needs a parent to be able to scan labware; use the Sanger Location
      parent_type = LocationType.find_or_create_by!(name: parent_type)
      parent = UnorderedLocation.create_with(
        location_type: parent_type
      ).find_or_create_by(name: parent_name)

      # Create the Destroyed Location Type
      location_type = LocationType.find_or_create_by!(name: location_type_name)

      begin
        # Use the specified Destroyed Location barcode; skip the callback to generate a barcode
        UnorderedLocation.skip_callback(:create, :after, :generate_barcode)

        # Create the Destroyed Location
        UnorderedLocation.create_with(
          barcode: location_barcode,
          location_type: location_type,
          parent: parent
        ).find_or_create_by(name: location_name)
      ensure
        # Restore the callback to generate a barcode
        UnorderedLocation.set_callback(:create, :after, :generate_barcode)
      end
    end
  end
end
