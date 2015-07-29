require "rails_helper"

RSpec.describe AvailableCoordinates, type: :model do
  
  before(:each) do
    Hash.grid(4, 4) do |pos, row, col|
      create(:coordinate, position: pos, row: row, column: col)
    end
  end

  it "should return the first line of coordinates that are available" do
    result = AvailableCoordinates.new(Coordinate.all, 10).result
    expect(result.length).to eq(10)
    expect(result.first.position).to eq(1)
    expect(result.last.position).to eq(10)
  end

  it "should return the first line of coordinates that are available after a filled coordinate" do
    Coordinate.find_by_position(position: 2).fill(create(:labware))
    result = AvailableCoordinates.new(Coordinate.all, 10).result
    expect(result.length).to eq(10)
    expect(result.first.position).to eq(3)
    expect(result.last.position).to eq(12)
  end

  it "should only return a line that is the length required" do
    Coordinate.find_by_position(position: 2).fill(create(:labware))
    Coordinate.find_by_position(position: 8).fill(create(:labware))
    result = AvailableCoordinates.new(Coordinate.all, 8).result
    expect(result.length).to eq(8)
    expect(result.first.position).to eq(9)
    expect(result.last.position).to eq(16)
  end

  it "should return an empty object if there aren't enough free spaces availables" do
    Coordinate.find_by_position(position: 2).fill(create(:labware))
    Coordinate.find_by_position(position: 8).fill(create(:labware))
    result = AvailableCoordinates.new(Coordinate.all, 10).result
    expect(result).to be_empty
  end
end