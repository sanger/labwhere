require 'rails_helper'

describe Location do

  it "is invalid without a name" do
    expect(build(:location, name: nil)).to_not be_valid
  end

  it "is invalid without a location type" do
    expect(build(:location, location_type: nil)).to_not be_valid
  end

  it "allows nesting locations" do
    parent_location = create(:location, name: "A parent location")
    child_location = create(:location, name: "A child location", parent: parent_location)
    expect(child_location.parent).to eq(parent_location)
    expect(parent_location.children.first).to eq(child_location)
  end

  it "#parents should produce a list of parents" do
    location_1 = create(:location)
    location_2 = create(:location, parent: location_1)
    location_3 = create(:location, parent: location_2)
    expect(location_3.parents).to eq([location_2, location_1])
  end

  it "should add a barcode after the location is created" do
    location = create(:location)
    expect(Location.find(location.id).barcode).to eq("#{location.name}:#{location.id}")
  end
  
end