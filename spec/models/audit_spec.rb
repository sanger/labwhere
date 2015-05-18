require 'rails_helper'

RSpec.describe Audit, type: :model do

  let!(:location) {create(:location)}
  
  it "should not be valid without a user" do
    expect(build(:audit, user: nil)).to_not be_valid
  end

  it "should not be valid without some record data" do
    expect(build(:audit, record_data: nil)).to_not be_valid
  end

  it "location should create an audit record with all of the correct attributes" do
    location = create(:location)
    user = create(:user)
    location.audits.create(action: "create", user: user, record_data: location.to_json)
    audit = location.audits.first
    expect(audit.auditable_id).to eq(location.id)
    expect(audit.auditable_type).to eq(location.class.to_s)
    expect(audit.action).to eq("create")
    expect(audit.user).to eq(user)
    expect(audit.record_data).to include(location.barcode)
    expect(audit.record_data).to include(location.name)
    expect(location.audits_count).to eq(1)
  end

end