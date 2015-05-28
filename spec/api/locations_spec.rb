#As a LIMS developer I want to be able to access the functionality of LabWhere via a RESTful API in order to integrate LIMS with it.
require "rails_helper"

RSpec.describe Api::Locations, type: :request do

  let!(:user) { create(:admin) }

  it "should retrieve information about a location get/api/locations/<barcode>" do
    location = create(:location)
    get api_location_path(location.barcode)
    expect(response).to be_success
    expect(response.body).to eq(location.to_json)
  end

  it "should create a new location" do
    post api_locations_path, location: attributes_for(:location).merge(user_code: user.swipe_card_id)
    expect(response).to be_success
    expect(response.body).to eq(Location.first.to_json)
  end

  it "should return an error if the location has invalid attributes" do
    post api_locations_path, location: attributes_for(:location).except(:name).merge(user_code: user.swipe_card_id)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(ActiveSupport::JSON.decode(response.body)["errors"]).not_to be_empty
  end

  it "should return an error if the user is invalid" do
    post api_locations_path, location: attributes_for(:location)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(ActiveSupport::JSON.decode(response.body)["errors"]).not_to be_empty
  end

  it "should update an existing location" do
    location = create(:location_with_parent)
    location_parent = create(:location)
    patch api_location_path(location.barcode), location: { user_code: user.swipe_card_id, parent_barcode: location_parent.barcode }
    expect(response).to be_success
    expect(location.reload.parent).to eq(location_parent)
  end
  
end