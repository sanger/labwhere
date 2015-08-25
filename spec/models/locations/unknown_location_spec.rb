require "rails_helper"

RSpec.describe UnknownLocation, type: :model do

  it "#get should return an unknown location" do
    location = UnknownLocation.get
    expect(location).to be_unknown
    expect(location.name).to eq("UNKNOWN")
  end

  it "should not be able to create more than one unknown location" do
    create(:unknown_location)
    location = build(:unknown_location)
    expect(location).to_not be_valid
    expect(location.errors.full_messages).to include("Can't have more than 1 UnknownLocation")
  end

  it "location should be valid without a location type if location is UNKNOWN" do
    expect(build(:unknown_location, location_type: nil)).to be_valid
  end

end