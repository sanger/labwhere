require "rails_helper"

RSpec.describe AddAudit, type: :model do

  with_model :my_model do
    table do |t|
      t.string :name
      t.integer :audits_count
    end

    model do
      has_many :audits, as: :auditable

      include AddAudit

    end
  end

  let!(:user) { create(:user)}

  it "should be able to build an audit record" do 
    my_model = MyModel.new(name: "My Model")
    my_model.build_audit(user, "create")
    audit = my_model.audits.first
    expect(audit.user).to eq(user)
    expect(audit.record_data).to eq(my_model.to_json)
  end

   it "should be able to create an audit record" do 
    my_model = MyModel.create(name: "My Model")
    my_model.create_audit(user, "create")
    audit = my_model.audits.first
    expect(audit.user).to eq(user)
    expect(audit.record_data).to eq(my_model.to_json)
  end
    
end
