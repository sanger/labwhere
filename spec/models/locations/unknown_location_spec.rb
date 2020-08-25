# frozen_string_literal: true

require "rails_helper"

RSpec.describe UnknownLocation, type: :model do
  it "#get should return an unknown location" do
    location = UnknownLocation.get
    expect(location).to be_unknown
    expect(location.name).to eq("UNKNOWN")
  end

  it "location should be valid without a location type if location is UNKNOWN" do
    expect(build(:unknown_location, location_type: nil)).to be_valid
  end

  context 'limiting to only one unknown location' do
    context 'when we are already at the limit of unknown locations' do
      before { create(:unknown_location) }

      it "should error when creating an unknown location" do
        location = build(:unknown_location)
        expect(location).to_not be_valid
        expect(location.errors.full_messages).to include(Location::UNKNOWN_LIMIT_ERROR)
      end

      it "should error when updating the type of a normal location to unknown" do
        location = create(:location)
        expect(location).to be_valid

        location.type = 'UnknownLocation'
        expect(location).to_not be_valid
        expect(location.errors.full_messages).to include(Location::UNKNOWN_LIMIT_ERROR)
      end
    end

    context 'when we are not yet at the limit of unknown locations' do
      it "should not error when creating an unknown location" do
        location = build(:unknown_location)
        expect(location).to be_valid
      end

      it "should not error when updating the type of a normal location to unknown" do
        location = create(:location)
        expect(location).to be_valid

        location.type = 'UnknownLocation'
        expect(location).to be_valid
      end
    end
  end
end
