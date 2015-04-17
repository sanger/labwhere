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

  it "should provide list of active/inactive locations" do
    locations_active = create_list(:location, 2)
    locations_inactive = create_list(:location, 2, active: false)
    expect(Location.count).to eq(4)
    expect(Location.active.count).to eq(2)
    expect(Location.inactive.count).to eq(2)
  end

  it "#inactive? should identify if a location has been deactivated" do
    expect(build(:location, active: false).inactive?).to be_truthy
  end

  it "#without_location should return a list of locations without a specified location" do
    locations = create_list(:location, 3)
    inactive_location = create(:location, active: false)
    expect(Location.without(locations.last).count).to eq(2)
    expect(Location.without(locations.last)).to_not include(locations.last)
    expect(Location.without(locations.last)).to_not include(inactive_location)
  end

  it "#residents should provide a message about the number of pieces of labware living in the location" do
    location_empty = build(:location)
    location_labware_1 = create(:location_with_parent, labwares: [build(:labware)])
    location_labware_3 = create(:location_with_parent, labwares: build_list(:labware, 3))

    expect(location_empty.residents).to eq("Location is empty")
    expect(location_labware_1.residents).to eq("Location has 1 piece of Labware")
    expect(location_labware_3.residents).to eq("Location has 3 pieces of Labware")
  end

  it "#unknown should return a location with name UNKNOWN" do
    expect(Location.unknown.name).to eq("UNKNOWN")
    expect(Location.unknown.unknown?).to be_truthy
  end

  it "location should be valid without a location type if location is UNKNOWN" do
    expect(build(:location, name: "UNKNOWN", location_type: nil)).to be_valid
  end

  it "changing a location to inactive should set deactivated_at to current date and time" do
    location = create(:location, active: true)
    expect(location.deactivated_at).to be_nil
    location.update(active: false)
    expect(location.deactivated_at).to_not be_nil
  end
  
end