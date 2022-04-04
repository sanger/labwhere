# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrderedLocation, type: :model do
  it "#populate should create correct number of coordinates from rows and columns" do
    location_1 = create(:ordered_location_with_parent, rows: 3, columns: 4)
    location_2 = create(:ordered_location_with_parent, rows: 1, columns: 1)

    Hash.grid(3, 4) do |pos, row, col|
      expect(location_1.coordinates.find_by_position(position: pos)).to_not be_nil
      expect(location_1.coordinates.find_by_position(position: pos)).to eq(location_1.coordinates.find_by_position(row: row, column: col))
    end

    expect(location_2.coordinates.find_by_position(row: 2, column: 2)).to be_nil
  end

  it "#available_coordinates returns coordinates which have no labware" do
    location = create(:ordered_location_with_parent, rows: 5, columns: 5)
    coordinates = location.available_coordinates(5, 10)
    expect(coordinates.length).to eq(10)
    expect(coordinates.first.position).to eq(5)
    expect(coordinates.last.position).to eq(14)

    location.coordinates.find_by_position(position: 10).fill(create(:labware))
    location.reload
    coordinates = location.available_coordinates(5, 10)
    expect(coordinates.length).to eq(10)
    expect(coordinates.first.position).to eq(5)
    expect(coordinates.last.position).to eq(15)

    coordinates = location.available_coordinates(20, 10)
    expect(coordinates.length).to eq(6)

    location = create(:ordered_location_with_labwares)
    expect(location.available_coordinates(5, 10)).to be_empty
  end

  it '#child_count returns correct number of children' do
    location = create(:ordered_location_with_labwares)
    expect(location.child_count).to eq(location.labwares.count)
  end

  describe 'destroying ordered locations' do
    it 'success' do
      ordered_location = build(:ordered_location_with_parent)
      puts ordered_location.coordinates
      ordered_location.coordinates.each { |coordinate| puts coordinate.errors.full_messages }
      ordered_location.destroy
      expect(ordered_location).to be_destroyed
    end
  end
end
