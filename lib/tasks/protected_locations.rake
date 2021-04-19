# frozen_string_literal: true

namespace :protected_locations do
  desc "Sets the protected flag to true for locations with certain location types"
  task set_default_protected_flag: :environment do
    protected_locations = ['Building', 'Room', 'Site', 'Car Park', 'Reefer', 'Bin', 'DELIVERED']
    Location.all.each do |location|
      if location.location_type_id.present?
        location_type = LocationType.find(location.location_type_id).name
        location.protected = true if protected_locations.include?(location_type)
        location.save
      end
      next
    end
    puts "-> Successfully added protection to: #{protected_locations} location types"
  end
end
