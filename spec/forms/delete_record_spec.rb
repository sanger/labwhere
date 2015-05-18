require "rails_helper"

RSpec.describe DeleteRecord, type: :model do 

  with_model :test_model do
    table do |t|
      t.string :name
    end

    model do
      before_destroy :check_name

      def check_name
        if name == "Please dont delete me"
          errors.add(:base, "Can't delete record")
          false
        else
          true
        end
      end
    end
  end

  let!(:user)               { create(:user)}
  let(:controller_params)   { { controller: "test_model", action: "destroy"} }
  let(:params)              { ActionController::Parameters.new(controller_params) }

  it "should destroy the record if it meets all of the requirements" do
    allow_any_instance_of(User).to receive(:allow?).and_return(true)
    record = TestModel.create(name: "A name")
    DeleteRecord.new(record).destroy(params.merge(user_code: user.barcode))
    expect(record).to be_destroyed
  end

  it "should not destroy the record if the user does not exist" do
    record = TestModel.create(name: "A name")
    delete_record = DeleteRecord.new(record)
    delete_record.destroy(params)
    expect(record).to_not be_destroyed
    expect(delete_record.errors.full_messages).to include("User #{I18n.t("errors.messages.existence")}")
  end

  it "should not destroy the record if the user is not authorised" do 
    allow_any_instance_of(User).to receive(:allow?).and_return(false)
    record = TestModel.create(name: "A name")
    delete_record = DeleteRecord.new(record)
    delete_record.destroy(params.merge(user_code: user.barcode))
    expect(record).to_not be_destroyed
    expect(delete_record.errors.full_messages).to include("User #{I18n.t("errors.messages.authorised")}")
  end

  it "should not destroy the record if the user is not authorised" do 
    allow_any_instance_of(User).to receive(:allow?).and_return(true)
    record = TestModel.create(name: "Please dont delete me")
    delete_record = DeleteRecord.new(record)
    delete_record.destroy(params.merge(user_code: user.barcode))
    expect(record).to_not be_destroyed
    expect(delete_record.errors.full_messages).to include("Can't delete record")
  end
    
end