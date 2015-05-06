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

  it "should add a barcode after the location is created" do
    location = create(:location)
    expect(location.reload.barcode).to eq("#{location.name}:#{location.id}")
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

  it "#update_labware_count should update labware_count to number of labwares" do
    location = create(:location_with_parent, labwares: create_list(:labware, 5))
    location.update_labwares_count
    expect(location.labwares_count).to eq(5)
  end

  it "#name should produce a list of location names" do
    location1 = create(:location)
    location2 = create(:location)
    expect(Location.names([location1, location2])).to eq("#{location1.name} #{location2.name}")
  end
  
end