require 'rails_helper'

describe LocationType do 

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
end