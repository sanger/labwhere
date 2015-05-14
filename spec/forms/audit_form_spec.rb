require "rails_helper"

RSpec.describe AuditForm, type: :model do 

   with_model :test_model do
    table do |t|
      t.string :name
      t.string :data
      t.timestamps null: false
    end

    model do
      validates_presence_of :name
    end
    
  end

  with_model :another_model do
    table do |t|
      t.string :name
      t.string :data
      t.timestamps null: false
    end
  end

  class TestModelForm
    include AuditForm
    set_attributes :name, :data
  end

  class AnotherModelForm
    include AuditForm
    set_attributes :name, :data
  end

  let(:controller_params)       { { controller: "test_model", action: "create"} }
  let(:valid_params)            { {name: "A name", data: "Some data"}}
  let(:params)                  { ActionController::Parameters.new(controller_params) }
  let!(:admin_user)             { create(:admin) }
  let!(:standard_user)          { create(:standard) }

  it "allows creation of new record with valid attributes" do
    expect{ 
      TestModelForm.new.submit(params.merge(test_model: valid_params.merge(user_code: admin_user.swipe_card_id)))
    }.to change(TestModel, :count).by(1)
  end

  it "prevents creation of new record with invalid attributes" do
    test_model_form = TestModelForm.new
    expect{ 
      test_model_form.submit(params.merge(test_model: valid_params.merge(name: nil, user_code: admin_user.swipe_card_id)))
    }.to_not change(TestModel, :count)
    expect(test_model_form.errors.count).to eq(1)
  end

  it "allows updating of existing record with valid attributes" do
    test_model_1 = TestModel.create(valid_params)
    test_model_form = TestModelForm.new(test_model_1)
    expect{
      test_model_form.submit(params.merge(test_model: valid_params.merge(name: "Another name", user_code: admin_user.barcode)))
    }.to change { test_model_1.reload.name }.to("Another name")
  end

  it "should reject modification of the record if the user is unknown" do
    test_model_form = TestModelForm.new
    expect{ 
      test_model_form.submit(params.merge(test_model: valid_params))
    }.to_not change(TestModel, :count)
    expect(test_model_form.errors.full_messages).to include("User #{I18n.t("errors.messages.existence")}")
  end

  it "should reject modification of the record if the user does not have authorisation" do
    test_model_form = TestModelForm.new
    expect{ 
      test_model_form.submit(params.merge(test_model: valid_params.merge(user_code: standard_user.swipe_card_id)))
    }.to_not change(TestModel, :count)
    expect(test_model_form.errors.full_messages).to include("User #{I18n.t("errors.messages.authorised")}")
  end

  it "should create an associated audit record" do
    TestModelForm.new.submit(params.merge(test_model: valid_params.merge(user_code: admin_user.swipe_card_id)))
    test_model = TestModel.first
    audit = Audit.find_by(record_id: test_model.id)
    expect(audit).to_not be_nil
    expect(audit.action).to eq("create")
    expect(audit.user).to eq(admin_user)
  end

end