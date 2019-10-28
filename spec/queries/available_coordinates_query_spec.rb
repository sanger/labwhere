# frozen_string_literal: true

require 'rails_helper'

describe AvailableCoordinatesQuery do
  let(:locations) { Location.all }
  let(:min_available_coordinates) { 10 }
  let(:result) { AvailableCoordinatesQuery.call(locations, min_available_coordinates) }

  before :all do
    @unordered_locations = create_list(:unordered_location_with_labwares, 5)
    @ordered_locations_with_labwares = create_list(:ordered_location_with_labwares, 5)
    @empty_ordered_locations = create_list(:ordered_location_with_parent, 5, rows: 5, columns: 5)
    @small_empty_ordered_locations = create_list(:ordered_location_with_parent, 5, rows: 3, columns: 3)

    @partially_filled_ordered_locations = create_list(:ordered_location_with_labwares, 5, rows: 5, columns: 5)
    @partially_filled_ordered_locations.each do |location|
      location.coordinates.shuffle.take(10).each do |coordinate|
        coordinate.update(labware: nil)
      end
    end
  end

  it 'filters out unordered locations' do
    expect(result).to_not include(*@unordered_locations)
  end

  it 'filters out ordered locations without enough space' do
    expect(result).to_not include(*@ordered_locations_with_labwares)
    expect(result).not_to include(*@small_empty_ordered_locations)
  end

  # it 'returns empty ordered locations with enough space' do
  #   expect(result).to include(*@empty_ordered_locations)
  # end

  # it 'returns partially filled locations with enough space' do
  #   expect(result).to include(*@partially_filled_ordered_locations)
  # end
end
