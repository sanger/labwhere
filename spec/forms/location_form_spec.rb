require "rails_helper"

RSpec.describe LocationForm, type: :model do

  let!(:location_type)      { create(:location_type)}
  let(:controller_params)   { { controller: "location", action: "create"} }
  let(:params)              { ActionController::Parameters.new(attributes_for(:location).merge(controller_params)) }
  let(:valid_params)        { params.merge(location_type_id: location_type.id) }
  let!(:admin_user)         { create(:admin) }
  let!(:standard_user)      { create(:standard) }

  it "allows creation of new location with valid attributes" do
    expect{ 
      LocationForm.new.submit(valid_params.merge(user: admin_user.swipe_card_id))
    }.to change(Location, :count).by(1)
  end

  it "prevents creation of new location with invalid attributes" do
    location_form = LocationForm.new
    expect{ 
      location_form.submit(params.merge(user: admin_user.swipe_card_id))
    }.to_not change(Location, :count)
    expect(location_form.errors.count).to eq(1)
  end

  it "allows updating of existing location with valid attributes" do
    location_1 = create(:location)
    location_2 = build(:location)
    location_form = LocationForm.new(location_1)
    expect{
      location_form.submit(params.merge(name: location_2.name, user: admin_user.barcode))
    }.to change { location_1.reload.name }.to(location_2.name)
  end

  it "should reject modification of the location if the user is unknown" do
    location_form = LocationForm.new
    expect{ 
      location_form.submit(valid_params)
    }.to_not change(Location, :count)
    expect(location_form.errors.full_messages).to include("User does not exist")
  end

  it "should reject modification of the location if the user does not have authorisation" do
    location_form = LocationForm.new
    expect{ 
      location_form.submit(valid_params.merge(user: standard_user.swipe_card_id))
    }.to_not change(Location, :count)
    expect(location_form.errors.full_messages).to include("User is not authorised")
  end

end