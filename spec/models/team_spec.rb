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

  it "#as_json should return the correct attributes" do
    team = create(:team)
    json = team.as_json
    expect(json["audits_count"]).to be_nil
    expect(json["created_at"]).to eq(team.created_at.to_s(:uk))
    expect(json["updated_at"]).to eq(team.updated_at.to_s(:uk))
  end

end
