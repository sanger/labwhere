require "rails_helper"

RSpec.describe Guest, type: :model do 

  it "should have a name" do
    expect(build(:guest).name).to eq("Guest")
  end

  it "should be a guest" do
    expect(build(:guest)).to be_guest
  end

  it "should not allow anything" do
    expect(build(:guest)).to_not allow(:any, :thing)
  end
end