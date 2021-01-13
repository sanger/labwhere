# frozen_string_literal: true

Dir[Rails.root.join('lib/location_creator/*.rb')].each { |f| require f }

desc "locations"
namespace :locations do
  desc "create some locations"
  task create: :environment do |_t|
    location_creator = LocationCreator.new("Site" => { location: "Sanger", container: false },
                                           "Building" => { location: "Ogilvie", container: false },
                                           "Room" => { location: "AA315", container: false },
                                           "Freezer" => { location: "Freezer1", container: true },
                                           "Shelf" => { location: "Shelf", number: 2, container: true },
                                           "Tray" => { location: "Tray", number: 208, container: true })
    location_creator.run!
  end
end
