# frozen_string_literal: true

Dir[Rails.root.join('lib/location_creator/*.rb')].each { |f| require f }

desc "locations"
namespace :locations do
  desc "create some locations"
  task create: :environment do |_t|
    location_creator = LocationCreator.new("Site" => { location: "Sanger" },
                                           "Building" => { location: "Ogilvie" },
                                           "Room" => { location: "AA315" },
                                           "Shelf" => { location: "Shelf", number: 2 },
                                           "Tray" => { location: "Tray", number: 208 })
    location_creator.run!
  end
end
