# frozen_string_literal: true

class LocationCreator
  attr_reader :locations

  def initialize(locations)
    @locations = locations
  end

  def run!
    generate!
  end

  private

  def generate!
    parents = [nil]
    locations.each do |k, v|
      parents = create_locations k, v, parents
    end
  end

  def create_locations(type, location, parents)
    location_type = LocationType.find_or_create_by(name: type)
    [].tap do |locations|
      parents.each do |parent|
        if location[:number]
          (1..location[:number]).each do |i|
            locations << create_location("#{location[:location]} #{i}", location_type, parent)
          end
        else
          locations << create_location(location[:location], location_type, parent)
        end
      end
    end
  end

  def create_location(location, location_type, parent)
    UnorderedLocation.find_or_create_by(name: location, parent_id: parent_id(parent)) do |l|
      l.location_type = location_type
    end
  end

  def parent_id(parent)
    parent.respond_to?(:id) ? parent.id : nil
  end
end
