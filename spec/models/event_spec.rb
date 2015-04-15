require 'rails_helper'

RSpec.describe Event, type: :model do
  it "should not be valid without a location" do
    expect(build(:event, location: nil)).to_not be_valid
  end

   it "should not be valid without a labware" do
    expect(build(:event, labware: nil)).to_not be_valid
  end
end
