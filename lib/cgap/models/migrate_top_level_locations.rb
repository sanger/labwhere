class MigrateTopLevelLocations

  include CreateLocationTypes

  def self.run!(path = "lib/cgap/data")
    new(path).run!
  end

  def initialize(path)
    LoadData.new("storage_equipment", path, "\r").load!
    @cgap_storages = CgapStorage.all 
    create_location_types
  end

  def run!

    sanger = UnorderedLocation.create(name: "Sanger", location_type: LocationType.find_by(name: "Site"), container: false)
    sulston = UnorderedLocation.create(name: "Sulston", location_type: LocationType.find_by(name: "Building"),container: false, parent: sanger)

    cgap_storages.pluck(:top_location).uniq.each do |name|
      UnorderedLocation.create(name: name, location_type: LocationType.find_by(name: "Room"), container: false, parent: sulston)
    end

    cgap_storages.each do |cgap_storage|
      cgap_storage.update_attribute(:labwhere_id, Location.find_by(name: cgap_storage.top_location).id)
    end
  end

private

  attr_reader :cgap_storages

end