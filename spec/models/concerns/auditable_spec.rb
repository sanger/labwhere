# frozen_string_literal: true

require "rails_helper"

RSpec.describe Auditable, type: :model do
  let!(:user) { create(:user) }
  let!(:location) { create(:location) }
  let!(:parent_location) { create(:location_with_parent) }
  let!(:location_with_parent) { create(:location_with_parent, parent: parent_location) }

  it "should be able to create an audit record" do
    location.create_audit(user, AuditAction::CREATE)
    audit = location.audits.first
    expect(audit.user).to eq(user)
    expect(audit.record_data.except("created_at", "updated_at")).to eq(location.as_json.except("created_at", "updated_at"))
    expect(location.reload.audits.count).to eq(1)
  end

  it "should add a method for converting dates to uk" do
    expect(location.uk_dates["created_at"]).to eq(location.created_at.to_s(:uk))
    expect(location.uk_dates["updated_at"]).to eq(location.updated_at.to_s(:uk))
  end

  it "should add an action if none is provided" do
    location.create_audit(user)
    expect(location.audits.last.action).to eq(AuditAction::CREATE)
    # Need to put the created date into the past because the test is too quick, so that created date and updated date are equal
    location.update_attributes(created_at: DateTime.now - 1)
    location.update_attributes(name: "New Name")
    location.create_audit(user)
    expect(location.audits.last.action).to eq(AuditAction::UPDATE)
  end

  context 'without write event method' do
    it 'does not write an event when creating an audit' do
      expect(Messages).not_to receive(:publish)
      location.create_audit(user)
    end
  end

  context 'with write event method' do
    # Labware is currently the only model that writes to the events warehouse
    # Tried testing more generically using expect(model_instance).to receive(:write_event)
    # But setting up the mock actually creates the method
    # This changes how the create_audit method behaves - respond_to? returns true
    let(:model_instance) { create(:labware) }

    it 'writes an event when creating an audit' do
      expect(Messages).to receive(:publish)
      model_instance.create_audit(user)
    end
  end
end
