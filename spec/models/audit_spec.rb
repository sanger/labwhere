# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Audit, type: :model do
  let!(:location)    { create(:location) }
  let!(:user)        { create(:user) }

  it 'has a uuid after creation' do
    expect(create(:audit).uuid).to be_present
  end

  it "should not be valid without a user" do
    expect(build(:audit, user: nil)).to_not be_valid
  end

  it "should not be valid without some record data" do
    expect(build(:audit, record_data: nil)).to_not be_valid
  end

  it "location should create an audit record with all of the correct attributes" do
    location.audits.create(action: "create", user: user, record_data: location)
    audit = location.audits.first
    expect(audit.auditable_id).to eq(location.id)
    expect(audit.auditable_type).to eq(location.class.to_s)
    expect(audit.action).to eq("create")
    expect(audit.user).to eq(user)
    expect(audit.record_data["barcode"]).to eq(location.barcode)
    expect(audit.record_data["name"]).to eq(location.name)
  end

  it "summary should be correct" do
    location.audits.create(action: "create", user: user, record_data: location)
    audit = location.audits.first
    expect(audit.summary).to eq("#{audit.action.capitalize}d by #{user.login} on #{audit.created_at.to_s(:uk)}")

    labware = create(:labware)
    labware.audits.create(action: "scan", user: user, record_data: location)
    audit = labware.audits.first
    expect(audit.summary).to eq("Scanned by #{user.login} on #{audit.created_at.to_s(:uk)}")
  end
end
