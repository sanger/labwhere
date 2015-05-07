require 'rails_helper'

RSpec.describe Team, type: :model do
  
  it "should not be valid without a number" do
    expect(build(:team, number: nil)).to_not be_valid
  end

  it "should not be valid unless number is an integer" do
    expect(build(:team, number: "xyz")).to_not be_valid
  end

  it "should not be valid without a name" do
    expect(build(:team, name: nil)).to_not be_valid
  end

  it "should not be valid without a unique number" do
    team = create(:team)
    expect(build(:team, number: team.number)).to_not be_valid
  end

  it "should not be valid without a unique name" do
    team = create(:team)
    expect(build(:team, name: team.name)).to_not be_valid
  end

end
