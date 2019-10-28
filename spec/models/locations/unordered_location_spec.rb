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

  it "#available_coordinates returns an empty set" do
    location = create(:unordered_location)
    expect(location.available_coordinates(5, 10)).to be_empty
  end
end
