require 'rails_helper'

RSpec.describe Scan, type: :model do

  it "location is empty should be valid" do
    expect(build(:scan)).to be_valid
  end

  it "if location is present should ensure it is a container" do
    expect(build(:scan, location: create(:location_with_parent, container: false))).to_not be_valid
  end

  it "if the location is present should ensure it is active" do
    expect(build(:scan, location: create(:location_with_parent, active: false))).to_not be_valid
  end

  it "if the location is present should ensure it has a parent" do
    expect(build(:scan, location: create(:location))).to_not be_valid
  end
end
