require "rails_helper"

RSpec.describe UserForm, type: :model do

  let!(:user)               { create(:standard)}
  let!(:admin_user)         { create(:admin)}
  let(:params)              { ActionController::Parameters.new(controller: "users", action: "update")}

  subject { UserForm.new(user) }

  it "if user is updated but swipe card id is left blank then swipe card id should not be updated" do
    expect{
      subject.submit(params.merge(user: { swipe_card_id: nil, user_code: admin_user.swipe_card_id }))
    }.to_not change {user.reload.swipe_card_id}
  end

  it "if user is updated but barcode is left blank then barcode should not be updated" do
     expect{
      subject.submit(params.merge(user: { barcode: nil, user_code: admin_user.swipe_card_id }))
    }.to_not change {user.reload.barcode}
  end

end