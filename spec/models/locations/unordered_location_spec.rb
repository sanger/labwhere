require "rails_helper"

RSpec.describe UnorderedLocation, type: :model do
  
  context "modifying status" do
    let!(:location_1) { create(:unordered_location) }
    let!(:location_2) { create(:unordered_location, parent: location_1) }
    let!(:location_3) { create(:unordered_location, parent: location_1) }
    let!(:location_4) { create(:unordered_location, parent: location_2) }
    let!(:location_5) { create(:unordered_location, parent: location_3) }

    it "deactivating should deactivate the whole family" do
      location_1.deactivate
      expect(location_2.reload).to be_inactive
      expect(location_3.reload).to be_inactive
      expect(location_4.reload).to be_inactive
      expect(location_5.reload).to be_inactive
    end

    it "activating a location should activate the whole family" do
      location_1.deactivate
      location_1.activate
      expect(location_2.reload).to be_active
      expect(location_3.reload).to be_active
      expect(location_4.reload).to be_active
      expect(location_5.reload).to be_active
    end

  end

  it "allows nesting of locations" do
    parent_location = create(:unordered_location, name: "A parent location")
    child_location = create(:unordered_location, name: "A child location", parent: parent_location)
    expect(child_location.parent).to eq(parent_location)
    expect(parent_location.children.first).to eq(child_location)
  end

  context "#available_coordinates" do

    it "should return available locations for the children of that location" do
      location = create(:unordered_location)
      child_location = create(:ordered_location, parent: location)
      locations = location.available_coordinates(10)
      expect(locations.length).to eq(1)
      expect(locations).to include(child_location)

      location_2 = create(:unordered_location)
      child_location_2 = create(:ordered_location_with_labwares, parent: location_2)
      expect(location_2.available_coordinates(10)).to be_empty
    end

    it "should return the location of the first child which are free" do
      location = create(:unordered_location)
      child_location_1 = create(:ordered_location_with_labwares, parent: location)
      child_location_2 = create(:ordered_location, parent: location)
      locations = location.available_coordinates(10)
      expect(locations.length).to eq(1)
      expect(locations).to include(child_location_2)
    end

    it "should return the locations anywhere in the location tree" do
      location = create(:unordered_location)
      child_location_1 = create(:unordered_location, parent: location)
      child_location_2 = create(:ordered_location, parent: location)
      child_location_3 = create(:ordered_location, parent: child_location_1)

      locations = location.available_coordinates(10)
      expect(locations.length).to eq(2)
      expect(locations).to include(child_location_2)
      expect(locations).to include(child_location_3)

      location_2 = create(:unordered_location)
      child_location_4 = create(:unordered_location, parent: location_2)
      child_location_5 = create(:ordered_location, parent: location_2)
      child_location_6 = create(:ordered_location_with_labwares, parent: child_location_1)

      locations = location_2.available_coordinates(10)
      expect(locations.length).to eq(1)
      expect(locations).to include(child_location_5)
    end
  end

end