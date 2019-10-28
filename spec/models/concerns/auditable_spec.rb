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

  let!(:user) { create(:user)}

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
    my_model.update_attributes(name: "New Name")
    my_model.create_audit(user)
    # expect(my_model.audits.last.action).to eq("update")
    my_model.destroy
    my_model.create_audit(user)
    expect(my_model.audits.last.action).to eq("destroy")
  end
    
end
