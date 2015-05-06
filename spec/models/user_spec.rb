require 'rails_helper'

RSpec.describe User, type: :model do

  it "should not be valid without a login" do
    expect(build(:user, login: nil)).to_not be_valid
  end

  it "should not be valid without a swipe card" do
    expect(build(:user, swipe_card: nil)).to_not be_valid
  end

  it "should not be valid without a barcode" do
    expect(build(:user, barcode: nil)).to_not be_valid
  end

  it "should not be valid without a unique login" do
    user = create(:user)
    expect(build(:user, login: user.login)).to_not be_valid
  end

  it "should be able to create an Admin user" do
    user = create(:user, type: "Admin")
    expect(Admin.all.count).to eq(1)
  end

  it "should be able to create an Standard user" do
    user = create(:user, type: "Standard")
    expect(Standard.all.count).to eq(1)
  end

end
