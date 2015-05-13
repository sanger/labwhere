require 'rails_helper'

RSpec.describe Audit, type: :model do

  let!(:location) {create(:location)}
  
  it "should not be valid without a record type" do
    expect(build(:audit, user: nil)).to_not be_valid
  end

  it "should not be valid without a record type" do
    expect(build(:audit, record_type: nil)).to_not be_valid
  end

  it "should not be valid without an action" do
    expect(build(:audit, action: nil)).to_not be_valid
  end

  it "should not be valid without some record data" do
    expect(build(:audit, record_data: nil)).to_not be_valid
  end

  it "should not be valid without a record id" do
    expect(build(:audit, record_id: nil)).to_not be_valid
  end

  it "#add should create an audit record with all of the correct attributes" do
    location = create(:location)
    user = create(:user)
    audit = Audit.add(location, user, "create")
    expect(audit.record_id).to eq(location.id)
    expect(audit.record_type).to eq(location.class.to_s)
    expect(audit.action).to eq("create")
    expect(audit.user).to eq(user)
    expect(audit.record_data).to eq(location.to_json)
  end

end