require "rails_helper"

RSpec.describe OrderedLocation, type: :model do

  it "#populate should create correct number of coordinates from rows and columns" do
    location_1 = create(:ordered_location_with_parent, rows: 3, columns: 4)
    location_2 = create(:ordered_location_with_parent, rows: 1, columns: 1)

    Hash.grid(3,4) do |pos, row, col|
      expect(location_1.coordinates.find_by_position(position: pos)).to_not be_nil
      expect(location_1.coordinates.find_by_position(position: pos)).to eq(location_1.coordinates.find_by_position(row: row, column: col))
    end

    expect(location_2.coordinates.find_by_position(row: 2, column: 2)).to be_nil

  end

  it "#available_coordinates should return location if location is available" do
    location = create(:ordered_location_with_parent)
    locations = location.available_coordinates(10)
    expect(locations.length).to eq(1)
    expect(locations).to include(location)

    location = create(:ordered_location_with_labwares)
    expect(location.available_coordinates(10)).to be_empty
  end
  
end