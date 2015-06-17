require "rails_helper"

RSpec.describe Auditor, type: :model do

  with_model :test_model do
    table do |t|
      t.string :name
      t.string :data
      t.integer :audits_count
      t.timestamps null: false
    end

    model do
      validates_presence_of :name
      has_many :audits, as: :auditable
      include AddAudit

    end
    
  end

  with_model :another_model do
    table do |t|
      t.string :name
      t.string :data
      t.integer :audits_count
      t.timestamps null: false
    end

    model do
      has_many :audits, as: :auditable
      include AddAudit
    end
  end

  class TestModelAudit
    include Auditor
    set_attributes :name, :data

    def before_destroy
      errors.add(:base, "Can't delete record") if name == "Please dont delete me"
    end
  end

  class AnotherModelAudit
    include Auditor
    set_attributes :name, :data
  end

  let(:controller_params)       { { controller: "test_model", action: "create"} }
  let(:valid_params)            { {name: "A name", data: "Some data"}}
  let(:params)                  { ActionController::Parameters.new(controller_params) }
  let!(:admin_user)             { create(:admin) }
  let!(:standard_user)          { create(:standard) }

  it "allows creation of new record with valid attributes" do
    expect{ 
      TestModelAudit.new.submit(params.merge(test_model: valid_params.merge(user_code: admin_user.swipe_card_id)))
    }.to change(TestModel, :count).by(1)
  end

  it "prevents creation of new record with invalid attributes" do
    test_model_form = TestModelAudit.new
    expect{ 
      test_model_form.submit(params.merge(test_model: valid_params.merge(name: nil, user_code: admin_user.swipe_card_id)))
    }.to_not change(TestModel, :count)
    expect(test_model_form.errors.count).to eq(1)
  end

  it "allows updating of existing record with valid attributes" do
    test_model_1 = TestModel.create(valid_params)
    test_model_form = TestModelAudit.new(test_model_1)
    expect{
      test_model_form.submit(params.merge(test_model: valid_params.merge(name: "Another name", user_code: admin_user.barcode)))
    }.to change { test_model_1.reload.name }.to("Another name")
  end

  it "should reject modification of the record if the user is unknown" do
    test_model_form = TestModelAudit.new
    expect{ 
      test_model_form.submit(params.merge(test_model: valid_params))
    }.to_not change(TestModel, :count)
    expect(test_model_form.errors.full_messages).to include("User #{I18n.t("errors.messages.existence")}")
  end

  it "should reject modification of the record if the user does not have authorisation" do
    test_model_form = TestModelAudit.new
    expect{ 
      test_model_form.submit(params.merge(test_model: valid_params.merge(user_code: standard_user.swipe_card_id)))
    }.to_not change(TestModel, :count)
    expect(test_model_form.errors.full_messages).to include("User #{I18n.t("errors.messages.authorised")}")
  end

  it "should reject modification of the record if the user is inactive" do
    test_model_form = TestModelAudit.new
    admin_user.deactivate
    expect{ 
      test_model_form.submit(params.merge(test_model: valid_params.merge(user_code: admin_user.swipe_card_id)))
    }.to_not change(TestModel, :count)
    expect(test_model_form.errors.full_messages).to include("User #{I18n.t("errors.messages.active")}")
  end

  it "should allow modification of the record if the user code is passed in the top level params" do
    expect{ 
      TestModelAudit.new.submit(params.merge(user_code: admin_user.swipe_card_id, test_model: valid_params))
    }.to change(TestModel, :count).by(1)
  end

  it "should create an associated audit record" do
    TestModelAudit.new.submit(params.merge(test_model: valid_params.merge(user_code: admin_user.swipe_card_id)))
    test_model = TestModel.first
    audit = Audit.find_by(auditable_id: test_model.id)
    expect(audit).to_not be_nil
    expect(audit.action).to eq("create")
    expect(audit.user).to eq(admin_user)
  end

   it "should destroy the record if it meets all of the requirements" do
    test_model = TestModel.create(valid_params)
    TestModelAudit.new(test_model).destroy(params.merge(action: "destroy", user_code: admin_user.barcode))
     audit = Audit.find_by(auditable_id: test_model.id)
    expect(audit).to_not be_nil
    expect(audit.action).to eq("destroy")
    expect(audit.user).to eq(admin_user)
  end

  it "should add an audit record if the record is destroyed" do
    test_model = TestModel.create(valid_params)
    TestModelAudit.new(test_model).destroy(params.merge(user_code: admin_user.barcode))
    expect(test_model).to be_destroyed
  end

  it "should not destroy the record if the user does not exist" do
    test_model = TestModel.create(valid_params)
    test_model_form = TestModelAudit.new(test_model)
    test_model_form.destroy(params)
    expect(test_model).to_not be_destroyed
    expect(test_model_form.errors.full_messages).to include("User #{I18n.t("errors.messages.existence")}")
  end

  it "should not destroy the record if the user is not authorised" do 
    test_model = TestModel.create(valid_params)
    test_model_form = TestModelAudit.new(test_model)
    test_model_form.destroy(params.merge(user_code: standard_user.barcode))
    expect(test_model).to_not be_destroyed
    expect(test_model_form.errors.full_messages).to include("User #{I18n.t("errors.messages.authorised")}")
  end

  it "should not destroy the record if the record is not destroyable" do 
    test_model = TestModel.create(valid_params.merge(name: "Please dont delete me"))
    test_model_form = TestModelAudit.new(test_model)
    test_model_form.destroy(params.merge(action: "destroy", user_code: admin_user.barcode))
    expect(test_model).to_not be_destroyed
    expect(test_model_form.errors.full_messages).to include("Can't delete record")
  end

end