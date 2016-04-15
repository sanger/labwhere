module Cgap
  module CreateLocationTypes

    LOCATION_TYPES =  [
                      "Site", "Building", "Room",
                      "Freezer -80C","CO2 Incubator", "Multi-Gas Incubator","Nitrogen Freezer",
                      "Freezer -20C","Fridge","Sonicator","Rotator",
                      "Thermoblock","Plate shaker","Automatic Incubator", "Bench",
                      "Shelf","Rack","Box","Drawer","Row","Slot","Floor","Platform","Stack"
                      ]

    def create_location_types
      LOCATION_TYPES.each do |location_type|
        LocationType.find_or_create_by(name: location_type)
      end
    end
    
  end
end