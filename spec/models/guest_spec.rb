require "rails_helper"

RSpec.describe Guest, type: :model do 

  it "should have a login" do
    expect(build(:guest).login).to eq("Guest")
  end

  it "should be a guest" do
    expect(build(:guest)).to be_guest
  end

  it "should not allow anything" do
    expect(build(:guest)).to_not allow_permission(:any, :thing)
  end
end