require "rails_helper"

RSpec.describe Users::AuditsController, type: :controller do
  it "should get index" do
    user = create(:user_with_audits)
    get :index, params: { user_id: user.id }
    expect(assigns(:audits)).to eq(user.audits)
  end
end
