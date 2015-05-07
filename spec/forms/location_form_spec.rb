require "rails_helper"

RSpec.describe LocationForm, type: :model do

  let!(:location_type) { create(:location_type)}
  let(:params)         { ActionController::Parameters.new(attributes_for(:location)) }
  let(:valid_params)   { params.merge(location_type_id: location_type.id) }

  it "submitting with valid attributes should create a new location" do
    expect{ 
      LocationForm.new.submit(valid_params)
    }.to change(Location, :count).by(1)
  end

  it "submitting with invalid attributes should return an error and not create a new location" do
    location_form = LocationForm.new
    expect{ 
      location_form.submit(params)
    }.to_not change(Location, :count)
    expect(location_form.errors.count).to eq(1)
  end

end