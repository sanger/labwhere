# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Audit, type: :model do
  let!(:location)     { create(:location) }
  let!(:user)         { create(:user) }
  let(:create_action) { AuditAction.new(AuditAction::CREATE) }

  it 'has a uuid after creation' do
    expect(create(:audit).uuid).to be_present
  end

  it "should not be valid without a user" do
    expect(build(:audit, user: nil)).to_not be_valid
  end

  it "should not be valid without some record data" do
    expect(build(:audit, record_data: nil)).to_not be_valid
  end

  it "will have an audit instance" do
    location.audits.create(action: "create", user: user, message: 'audit message', record_data: location)
    audit = location.audits.first
    expect(audit.action_instance).to eq(AuditAction.new("create"))
  end

  it "location should create an audit record with all of the correct attributes" do
    location.audits.create(action: "create", user: user, message: 'audit message', record_data: location)
    audit = location.audits.first
    expect(audit.auditable_id).to eq(location.id)
    expect(audit.auditable_type).to eq(location.class.to_s)
    expect(audit.action).to eq("create")
    expect(audit.user).to eq(user)
    expect(audit.message).to eq('audit message')
    expect(audit.record_data["barcode"]).to eq(location.barcode)
    expect(audit.record_data["name"]).to eq(location.name)
  end

  it "summary should be correct" do
    location.audits.create(user: user, record_data: location)
    audit = location.audits.first
    expect(audit.summary).to eq("#{create_action.display_text} by #{user.login} on #{audit.created_at.to_s(:uk)}")

    labware = create(:labware)
    labware.audits.create(message: "rideontime", user: user, record_data: location)
    audit = labware.audits.first
    expect(audit.summary).to eq("rideontime by #{user.login} on #{audit.created_at.to_s(:uk)}")
  end

  describe "action" do
    it "when action is passed" do
      audit = Audit.create(action: "wishitwassummer", user: user, record_data: location, auditable: location)
      expect(audit.action).to eq("wishitwassummer")
    end

    context "when action is not passed" do
      it "when the record is being created" do
        audit = Audit.create(user: user, record_data: location, auditable: location)
        expect(audit.action).to eq(AuditAction::CREATE)
      end

      it "when the record is being updated" do
        location.audits.create(action: "create", user: user, record_data: location)
        audit = Audit.create(user: user, record_data: location, auditable: location)
        expect(audit.action).to eq(AuditAction::UPDATE)
      end

      it "when the record is being destroyed" do
        location.destroy
        audit = Audit.create(user: user, record_data: location, auditable: location)
        expect(audit.action).to eq(AuditAction::DESTROY)
      end
    end
  end

  it "can have a message" do
    audit = Audit.create(message: "wishitwassummer", user: user, record_data: location, auditable: location)
    expect(audit.message).to eq("wishitwassummer")
  end
end
