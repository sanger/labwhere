require "rails_helper"

RSpec.describe LocationTypes::AuditsController, type: :controller do

  it "should get index" do
    location_type = create(:location_type_with_audits)
    get :index, params: { location_type_id: location_type.id }
    expect(assigns(:audits)).to eq(location_type.audits)
  end
  
end