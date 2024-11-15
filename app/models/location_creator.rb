# frozen_string_literal: true

# Create locations. Useful for dummy data
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
    location_type = LocationType.find_or_create_by!(name: type)
    [].tap do |locations|
      parents.each do |parent|
        if location[:number]
          (1..location[:number]).each do |i|
            locations << create_location("#{location[:location]} #{i}", location_type, parent, location[:container],
                                         location[:barcode])
          end
        else
          locations << create_location(location[:location], location_type, parent, location[:container],
                                       location[:barcode])
        end
      end
    end
  end

  def create_location(location, location_type, parent, container, barcode)
    puts "Creating location: #{location} #{barcode}"

    find_or_create_attributes = { name: location, container: container }
    find_or_create_attributes[:barcode] = barcode if barcode.present?

    UnorderedLocation.find_or_create_by!(find_or_create_attributes) do |l|
      l.parent = parent
      l.location_type = location_type
    end
  end
end
