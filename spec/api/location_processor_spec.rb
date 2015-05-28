require "rails_helper"

RSpec.describe LocationProcessor, type: :model do

  let(:controller_params)       { { controller: "locations", action: "create"} }
  let(:params)                  { ActionController::Parameters.new(controller_params) }
  let!(:admin_user)             { create(:admin) }
  let!(:parent_location)        { create(:location)}
  let(:location_params)         { attributes_for(:location).except(:parent) }

  it "should create a new location" do
    location_processor = LocationProcessor.new
    expect { 
      location_processor.submit(
        params.merge(location: location_params.merge(user_code: admin_user.barcode, parent_barcode: parent_location.barcode)))
      }.to change(Location, :count).by(1)
    expect(location_processor.location.parent).to eq(parent_location)
  end

  it "should have an empty parent if no parent barcode is passed" do
    location_processor = LocationProcessor.new
    location_processor.submit(params.merge(location: location_params.merge(user_code: admin_user.barcode)))
    expect(location_processor.location.parent).to be_empty
  end

  it "should produce valid json" do
    location_processor = LocationProcessor.new
    location_processor.submit(params.merge(location: location_params.merge(user_code: admin_user.barcode)))
    expect(location_processor.to_json).to eq(location_processor.location.to_json)
  end
  
end