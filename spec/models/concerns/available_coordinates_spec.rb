# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AvailableCoordinates, type: :model do
  let!(:location) { create(:location_with_parent) }

  before(:each) do
    Hash.grid(4, 4) do |pos, row, col|
      create(:coordinate, location: location, position: pos, row: row, column: col)
    end
  end

  it 'should return the location if enough coordinates are available' do
    expect(AvailableCoordinates.new(Coordinate.all, 10).find).to eq(location)
  end

  it 'should return the location if some coordinates are available anywhere' do
    Coordinate.find_by_position(position: 2).fill(create(:labware))
    expect(AvailableCoordinates.new(Coordinate.all, 10).find).to eq(location)
  end

  it 'should still return the location whatever length required' do
    Coordinate.find_by_position(position: 2).fill(create(:labware))
    Coordinate.find_by_position(position: 8).fill(create(:labware))
    expect(AvailableCoordinates.find(Coordinate.all, 8)).to eq(location)
  end

  it "should return an empty object if there aren't enough free spaces availables" do
    Coordinate.find_by_position(position: 2).fill(create(:labware))
    Coordinate.find_by_position(position: 8).fill(create(:labware))
    expect(AvailableCoordinates.find(Coordinate.all, 10)).to be_nil
  end
end
