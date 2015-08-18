require "rails_helper"

RSpec.describe Auditable, type: :model do

  with_model :my_model do
    table do |t|
      t.string :name
      t.integer :audits_count
      t.timestamps null: false
    end

    model do

      include Auditable

    end
  end

  let!(:user) { create(:user)}

  it "should be able to build an audit record" do 
    my_model = MyModel.new(name: "My Model")
    my_model.build_audit(user, "create")
    audit = my_model.audits.first
    expect(audit.user).to eq(user)
    expect(audit.record_data).to eq(my_model.as_json)
  end

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
    
end
