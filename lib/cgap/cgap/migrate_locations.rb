# frozen_string_literal: true

module Cgap
  class MigrateLocations
    include CreateLocationTypes

    LOCATION_TYPE_MATCHES = { "-80 freezer" => "Freezer -80C",
                              "CO2 Incubator" => "CO2 Incubator",
                              "Multi-Gas Incubator" => "Multi-Gas Incubator",
                              "CryoStore" => "Nitrogen Freezer",
                              "Underbench -80" => "Freezer -80C",
                              "Underbench freezer" => "Freezer -20C",
                              "Underbench fridge" => "Fridge",
                              "Upright freezer" => "Freezer -20C",
                              "Upright fridge" => "Fridge",
                              "Bench" => "Bench",
                              "Covaris" => "Sonicator",
                              "rotator" => "Rotator",
                              "Thermoblock" => "Thermoblock",
                              "Plate shaker" => "Plate shaker",
                              "Cytomatic incubator" => "Automatic Incubator",
                              "Shelf" => "Shelf",
                              "Rack" => "Rack",
                              "Box" => "Box",
                              "Drawer" => "Drawer",
                              "Row" => "Row",
                              "Slot" => "Slot",
                              "Floor" => "Floor",
                              "Platform" => "Platform",
                              "Stack" => "Stack" }

    def self.run!(path = "lib/cgap/data")
      new(path).run!
    end

    def initialize(path)
      Cgap::LoadData.new("locations_top", path).load!
      Cgap::LoadData.new("locations_sub", path).load!
      @cgap_locations = Cgap::Location.all
      create_location_types
    end

    def run!
      cgap_locations.each do |cgap_location|
        location = new_location(cgap_location)
        location.save
        cgap_location.update_attribute(:labwhere_id, location.id)
      end

      add_top_level_parents
      add_parents
      add_coordinates
    end

    def add_top_level_parents
      Cgap::Location.where.not(barcode: nil).each do |cgap_location|
        ::Location.find(cgap_location.labwhere_id).update_attribute(:parent_id, Cgap::Storage.find_by(barcode: cgap_location.barcode).labwhere_id)
      end
    end

    def add_parents
      Cgap::Location.where.not(parent_id: nil).each do |cgap_location|
        ::Location.find(cgap_location.labwhere_id).update_attribute(:parent_id, cgap_location.parent.labwhere_id)
      end
    end

    def add_coordinates
      ::Location.where("rows > 0 and columns > 0").each do |location|
        location = location.transform
        location.populate_coordinates
        location.save
      end
    end

    private

    attr_reader :cgap_locations

    def find_location_type(name)
      location_type = LOCATION_TYPE_MATCHES.detect { |k, _v| name.downcase.include?(k.downcase) }
      LocationType.find_by(name: location_type.last)
    end

    def new_location(cgap_location)
      ::Location.new(
        name: create_unique_name(cgap_location),
        rows: cgap_location.rows,
        columns: cgap_location.columns,
        location_type: find_location_type(cgap_location.name)
      )
    end

    def create_unique_name(cgap_location)
      name = cgap_location.name
      ::Location.where(["name LIKE ?", name]).present? ? "#{name} #{cgap_location.id}" : name
    end
  end
end
