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

  it "#has_locations? should signify whether a location type can be destroyed" do
    location_type = create(:location_type)
    location = create(:location, location_type: location_type)
    expect(location_type.has_locations?).to be_truthy
  end

   it "#has_locations? should signify whether a location type can be destroyed" do
    location_type = create(:location_type)
    expect(location_type.has_locations?).to be_falsey
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

  it "#as_json should have the correct attributes" do
    location_type = create(:location_type)
    json = location_type.as_json
    expect(json["locations_count"]).to be_nil
    expect(json["audits_count"]).to be_nil
    expect(json["created_at"]).to eq(location_type.created_at.to_s(:uk))
    expect(json["updated_at"]).to eq(location_type.updated_at.to_s(:uk))

  end

end