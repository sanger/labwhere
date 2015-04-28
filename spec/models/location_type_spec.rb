#(l1) As a SM manager (Admin) I want to create new locations to enable RAS's track labware whereabouts.

require 'rails_helper'

RSpec.describe LocationType, type: :model do 

  it "is invalid without a name" do
    expect(build(:location_type, name: nil)).to_not be_valid
  end

  it "is invalid without a unique name" do
    create(:location_type, name: "Unique Name")
    expect(build(:location_type, name: "Unique Name")).to_not be_valid
  end

  it "should allow name to be case insensitive" do
    create(:location_type, name: "Unique Name")
    expect(build(:location_type, name: "unique name")).to_not be_valid
  end

  it "should only be deleted if it has not been used for a location" do
    location_type = create(:location_type)
    location = create(:location, location_type: location_type)
    location_type.destroy
    expect(location_type.errors.full_messages).to include("Can't delete a location type which is being used for a location.")
  end

  it "#ordered should produce a list ordered by name" do
    location_type_1 = LocationType.create(name: "abc")
    location_type_2 = LocationType.create(name: "abc1")
    location_type_3 = LocationType.create(name: "bacd")
    expect(LocationType.ordered.count).to eq(3)
    expect(LocationType.ordered.first.name).to eq("abc")
    expect(LocationType.ordered.last.name).to eq("bacd")
  end

  it "should implement a counter cache for locations" do
    location_type = create(:location_type)
    create(:location, location_type: location_type)
    create(:location, location_type: location_type)
    expect(location_type.locations_count).to eq(2)
    Location.last.destroy
    expect(location_type.reload.locations_count).to eq(1)
  end
end