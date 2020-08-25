# frozen_string_literal: true

require "rails_helper"

RSpec.describe Auditable, type: :model do
  with_model :my_model do
    table do |t|
      t.string :name
      t.timestamps null: false
    end

    model do
      include Auditable
    end
  end

  let!(:user) { create(:user) }

  it "should be able to create an audit record" do
    my_model = MyModel.create(name: "My Model")
    my_model.create_audit(user, "create")
    audit = my_model.audits.first
    expect(audit.user).to eq(user)
    expect(audit.record_data.except("created_at", "updated_at")).to eq(my_model.as_json.except("created_at", "updated_at"))
    expect(my_model.reload.audits.count).to eq(1)
  end

  it "should add a method for converting dates to uk" do
    my_model = MyModel.create(name: "My Model")
    expect(my_model.uk_dates["created_at"]).to eq(my_model.created_at.to_s(:uk))
    expect(my_model.uk_dates["updated_at"]).to eq(my_model.updated_at.to_s(:uk))
  end

  it "should add an action if none is provided" do
    my_model = MyModel.create(name: "My Model")
    my_model.create_audit(user)
    expect(my_model.audits.last.action).to eq("create")
    # Need to put the created date into the past because the test is too quick, so that created date and updated date are equal
    my_model.update_attributes(created_at: DateTime.now - 1)
    my_model.update_attributes(name: "New Name")
    my_model.create_audit(user)
    expect(my_model.audits.last.action).to eq("update")
    my_model.destroy
    my_model.create_audit(user)
    expect(my_model.audits.last.action).to eq("destroy")
  end

  context 'without write event method' do
    it 'does not write an event when creating an audit' do
      model_instance = MyModel.create(name: "My Model")

      expect(Messages).not_to receive(:publish)
      model_instance.create_audit(user)
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
