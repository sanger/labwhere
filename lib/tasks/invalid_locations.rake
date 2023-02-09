# frozen_string_literal: true

desc 'Print out all the locations that fail validation'
task invalid_locations: :environment do
  has_failures = false
  format = "%-20s\t%-20s\t%-20s\t%-20s\n"

  Location.all.each do |location|
    next if location.valid?

    # Print out some nicely formatted headers
    unless has_failures
      printf(format, 'Name', 'Location Type', 'Parentage', 'Parent Location Type')
      printf(format, '----', '-------------', '---------', '--------------------')
    end

    # NullLocation doesn't have a LocationType so we need to do a check first
    parent_name = location.parent.location_type.name if location.parent.respond_to? :location_type

    printf(format, location.name, location.location_type.name, location.parentage, parent_name)

    has_failures = true
  end

  puts 'All locations passed' unless has_failures
end
