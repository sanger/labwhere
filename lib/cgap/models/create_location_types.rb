module CreateLocationTypes

  LOCATION_TYPES =  [
                    "Freezer -80C","CO2 Incubator", "Multi-Gas Incubator","Nitrogen Freezer",
                    "Freezer -20C","Fridge","Sonicator","Rotator",
                    "Thermoblock","Plate shaker","Automatic Incubator"
                    ]

  def create_location_types
    LOCATION_TYPES.each do |location_type|
      LocationType.find_or_create_by(name: location_type)
    end
  end
  
end