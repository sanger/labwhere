#(l1) As a SM manager (Admin) I want to create new locations to enable RAS's track labware whereabouts.

require 'rails_helper'

RSpec.describe Location, type: :model do

  it "is invalid without a name" do
    expect(build(:location, name: nil)).to_not be_valid
  end

  it "is invalid without a location type" do
    expect(build(:location, location_type: nil)).to_not be_valid
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
    location = create(:location, name: "Location1")
    expect(location.barcode).to eq("location1-#{location.id}")
  end

  it "#as_json should return the correct attributes" do
    location_type = create(:location_type)
    location = create(:location, location_type: location_type)
    json = location.as_json
    expect(json["deactivated_at"]).to be_nil
    expect(json["created_at"]).to eq(location.created_at.to_s(:uk))
    expect(json["updated_at"]).to eq(location.updated_at.to_s(:uk))
    expect(json["location_type_id"]).to be_nil
    expect(json["location_type"]).to eq(location_type.name)
  end

  it "should add the parentage when a location is created" do
    location_1 = create(:location)
    expect(location_1.parentage).to be_blank

    location_2 = create(:location, parent: location_1)
    location_3 = create(:location, parent: location_2)
    expect(location_3.parentage).to eq("#{location_1.name} / #{location_2.name}")
  end

  it "should update the parentage when a parent is updated" do
    location_1 = create(:unordered_location)
    location_2 = create(:unordered_location)

    location_3 = create(:unordered_location, parent: location_1)
    location_4 = create(:unordered_location, parent: location_3)
    location_5 = create(:ordered_location, parent: location_4)

    location_3.update_attribute(:parent, location_2)
    expect(location_3.reload.parentage).to eq(location_2.name)
    expect(location_4.reload.parentage).to eq("#{location_2.name} / #{location_3.name}")
    expect(location_5.reload.parentage).to eq("#{location_2.name} / #{location_3.name} / #{location_4.name}")

  end

  it "#coordinateable? should determine if location has rows and columns" do
    expect(create(:location)).to_not be_coordinateable
    expect(create(:location, rows: 1, columns: 1)).to be_coordinateable
  end

  it "#transform should transform location to be the correct type and have the correct type attribute" do
    location_1 = build(:location)
    location_1 = location_1.transform
    expect(location_1).to be_unordered
    location_2 = build(:location, rows: 5, columns: 5)
    location_2 = location_2.transform
    expect(location_2).to be_ordered
  end

  it "unknown location should just create labwares and location should be unknown" do
    location = Location.unknown
    labwares = create_list(:labware, 3)
    expect(location.add_labwares(labwares.join_barcodes).count).to eq(3)
    expect(location.labwares.count).to eq(3)
  end

  it "#add_labwares should remove any dodgy control character from barcodes" do
    location = create(:location_with_parent)
    labwares = create_list(:labware, 3)
    location.add_labwares(labwares.join_barcodes("\n\r"))
    expect(location.labwares.count).to eq(3)
    expect(location.labwares.all? {|labware| !labware.barcode.include?("\r") }).to be_truthy
  end
  
end