require 'rails_helper'

RSpec.describe Coordinate, type: :model do

  it "is not valid without a position" do
    expect(build(:coordinate, position: nil)).to_not be_valid
  end

  it "is not valid without a row" do
    expect(build(:coordinate, row: nil)).to_not be_valid
  end

  it "is not valid without a column" do
    expect(build(:coordinate, column: nil)).to_not be_valid
  end

  it "is not valid without a numerical position" do
    expect(build(:coordinate, position: "xyz")).to_not be_valid
  end

  it "is not valid without a numerical row" do
    expect(build(:coordinate, row: "xyz")).to_not be_valid
  end

  it "is not valid without a numerical column" do
    expect(build(:coordinate, column: "xyz")).to_not be_valid
  end

  it "is not valid without a location" do
    expect(build(:coordinate, location: nil)).to_not be_valid
  end

  it "is not valid without a nested location" do
    expect(build(:coordinate, location: create(:location))).to_not be_valid
  end

  it "should be findable by its position" do
    coordinate = create(:coordinate, position: 4, row: 2, column: 3)
    expect(Coordinate.find_by_position(position: 4)).to eq(coordinate)
    expect(Coordinate.find_by_position(row: 2, column: 3)).to eq(coordinate)
    expect(Coordinate.find_by_position(position: 10)).to be_nil
  end

  it "#filled? should determine whether there is a labware in the coordinate" do
    coordinate = create(:coordinate, labware: create(:labware))
    expect(coordinate).to be_filled
    coordinate = create(:coordinate)
    expect(coordinate).to_not be_filled
  end

  it "#fill should add a labware to a particular coordinate" do
    coordinate = create(:coordinate)
    expect(coordinate).to_not be_filled
    coordinate.fill(create(:labware))
    expect(coordinate).to be_filled
  end

  it "#fill should update all of the associated attributes" do
    coordinate = create(:coordinate)
    labware = build(:labware)
    coordinate.fill(labware)
    created_labware = Labware.find_by_code(labware.barcode)
    expect(coordinate.reload.labware_id).to eq(created_labware.id)
    expect(created_labware.coordinate_id).to eq(coordinate.reload.id)
  end
 
end
