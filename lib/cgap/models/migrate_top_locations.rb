class MigrateTopLocations

  include CreateLocationTypes

  LOCATION_TYPE_MATCHES = { "-80 freezer (dual compressor) MDFU500VX-PE" => "Freezer -80C",
                            "-80 freezer MDFU443" => "Freezer -80C",
                            "-80 freezer MDFU55V" => "Freezer -80C",
                            "Air Jacket CO2 Incubator Panasonic MCO-19AIC(UV)-PE" => "CO2 Incubator", 
                            "Air Jacket Multi-Gas Incubator Panasonic MCO-19M-PE" => "Multi-Gas Incubator",
                            "CryoStore Labs 20K" => "Nitrogen Freezer",
                            "CryoStore Labs 40K" => "Nitrogen Freezer",
                            "Underbench -80 Innova U101" => "Freezer -80C",
                            "Underbench freezer Liebherr" => "Freezer -20C",
                            "Underbench fridge Liebherr" => "Fridge",
                            "Upright freezer Liebherr" => "Freezer -20C",
                            "Upright fridge Liebherr" => "Fridge",
                            "Bench" => "Bench",
                            "Covaris" => "Sonicator",
                            "Eppendorf rotator" => "Rotator",
                            "Thermoblock" => "Thermoblock",
                            "Plate shaker" => "Plate shaker",
                            "Cytomatic incubator" => "Automatic Incubator"}

  def self.run!
    new.run!
  end

  def initialize
    @top_locations = CgapTopLocation.all
    create_location_types
  end

  def run!
    top_locations.each do |top_location|
      location = Location.create(name: top_location.name, location_type: find_location_type(top_location.name))
      top_location.update_attribute(:labwhere_id, location.id)
    end
  end

private

  attr_reader :top_locations

  def find_location_type(key)
    LocationType.find_by(name: LOCATION_TYPE_MATCHES[key])
  end
  
end