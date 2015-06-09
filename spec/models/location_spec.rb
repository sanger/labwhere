#(l1) As a SM manager (Admin) I want to create new locations to enable RAS's track labware whereabouts.

require 'rails_helper'

RSpec.describe Location, type: :model do

  it "is invalid without a name" do
    expect(build(:location, name: nil)).to_not be_valid
  end

  it "is invalid without a location type" do
    expect(build(:location, location_type: nil)).to_not be_valid
  end

  it "allows nesting of locations" do
    parent_location = create(:location, name: "A parent location")
    child_location = create(:location, name: "A child location", parent: parent_location)
    expect(child_location.parent).to eq(parent_location)
    expect(parent_location.children.first).to eq(child_location)
  end

  it "#without_location should return a list of locations without a specified location" do
    locations = create_list(:location, 3)
    inactive_location = create(:location, status: Location.statuses[:inactive])
    expect(Location.without(locations.last).count).to eq(2)
    expect(Location.without(locations.last)).to_not include(locations.last)
    expect(Location.without(locations.last)).to_not include(inactive_location)
  end

  it "#unknown should return a location with name UNKNOWN" do
    expect(Location.unknown.name).to eq("UNKNOWN")
    expect(Location.unknown.unknown?).to be_truthy
  end

  it "location should be valid without a location type if location is UNKNOWN" do
    expect(build(:location, name: "UNKNOWN", location_type: nil)).to be_valid
  end

  it "#name should produce a list of location names" do
    location1 = create(:location)
    location2 = create(:location)
    expect(Location.names([location1, location2])).to eq("#{location1.name} #{location2.name}")
  end

  it "#find_by_code should find a location by it's barcode" do
    location1 = create(:location)
    location2 = create(:location)
    expect(Location.find_by_code(location1.barcode)).to eq(location1)
  end

  it "#reset_labwares_count should update labware counts for locations" do
    location_1 = create(:location_with_parent, labwares: create_list(:labware, 5))
    location_2 = create(:location_with_parent, labwares: create_list(:labware, 3))

    Location.reset_labwares_count(Location.all)
    expect(location_1.reload.labwares_count).to eq(5)
    expect(location_2.reload.labwares_count).to eq(3)

    location_1.labwares.delete_all
    Location.reset_labwares_count(Location.all)
    expect(location_1.labwares.count).to eq(0)

  end

  it "name should not be valid with characters that aren't words, numbers, hyphens or spaces" do
    expect(build(:location, name: "location 1")).to be_valid
    expect(build(:location, name: "location one")).to be_valid
    expect(build(:location, name: "location-one")).to be_valid
    expect(build(:location, name: "location-one one")).to be_valid
    expect(build(:location, name: "A location +++")).to_not be_valid
    expect(build(:location, name: "A/location")).to_not be_valid
    expect(build(:location, name: "A location ~")).to_not be_valid
  end

  it "name should not be valid if it is more than 50 characters long" do
    expect(build(:location, name: "l"*49)).to be_valid
    expect(build(:location, name: "l"*50)).to be_valid
    expect(build(:location, name: "l"*51)).to_not be_valid
  end

  it "barcode should be sanitised" do
    location = create(:location, name: "location1")
    expect(location.barcode).to eq("location1-#{location.id}")
    location = create(:location, name: "location 1")
    expect(location.barcode).to eq("location-1-#{location.id}")
  end
  
end