# frozen_string_literal: true

require "rails_helper"

RSpec.describe UnorderedLocation, type: :model do
  context "modifying status" do
    let!(:location1) { create(:unordered_location) }
    let!(:location2) { create(:unordered_location, parent: location1) }
    let!(:location3) { create(:unordered_location, parent: location1) }
    let!(:location4) { create(:unordered_location, parent: location2) }
    let!(:location5) { create(:unordered_location, parent: location3) }

    it "deactivating should deactivate the whole family" do
      location1.deactivate
      expect(location2.reload).to be_inactive
      expect(location3.reload).to be_inactive
      expect(location4.reload).to be_inactive
      expect(location5.reload).to be_inactive
    end

    it "activating a location should activate the whole family" do
      location1.deactivate
      location1.activate
      expect(location2.reload).to be_active
      expect(location3.reload).to be_active
      expect(location4.reload).to be_active
      expect(location5.reload).to be_active
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

  describe "audit message" do
    let(:create_action) { AuditAction.new(AuditAction::CREATE) }

    let!(:user) { create(:user) }

    let!(:location) { create(:unordered_location_with_parent) }

    it "will create the correct message" do
      audit = location.create_audit(user)
      expect(audit.message).to eq("#{create_action.display_text} and stored in #{location.breadcrumbs}")
    end
  end
end
