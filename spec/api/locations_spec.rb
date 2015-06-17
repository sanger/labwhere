# As a LIMS developer I want to be able to access the functionality of LabWhere via a RESTful API in order to integrate LIMS with it.
# Create locations
require "rails_helper"

RSpec.describe Api::LocationsController, type: :request do

  let!(:user) { create(:admin) }

  it "should retrieve information about locations get /api/locations" do
    locations = create_list(:location, 5)
    get api_locations_path
    expect(response).to be_success
    expect(ActiveSupport::JSON.decode(response.body).length).to eq(locations.length)
  end

  it "locations should not include location unknown" do
    locations = create_list(:location, 5)
    location_unknown = Location.unknown
    get api_locations_path
    expect(response.body).to_not include(location_unknown.name)
  end

  it "should retrieve information about a location get /api/locations/<barcode>" do
    location = create(:location_with_parent)
    get api_location_path(location.barcode)
    expect(response).to be_success
    json = ActiveSupport::JSON.decode(response.body)
    expect(json["name"]).to eq(location.name)
    expect(json["parent"]).to eq(location.parent.name)
    expect(json["container"]).to eq(location.container)
    expect(json["status"]).to eq(location.status)
    expect(json["location_type_id"]).to eq(location.location_type_id)
    expect(json["created_at"]).to eq(location.created_at.to_s(:uk))
    expect(json["updated_at"]).to eq(location.updated_at.to_s(:uk))
    expect(json["labwares"]).to eq(api_location_labwares_path(location.barcode))
    expect(json["audits"]).to eq(api_location_audits_path(location.barcode))
    expect(json["barcode"]).to eq(location.barcode)
    expect(json["children"]).to eq(api_location_children_path(location.barcode))
    expect(json["id"]).to eq(location.id)
  end

  it "should retrieve information about a locations labwares get api/locations/<barcode>/labwares" do
    location = create(:location_with_labwares)
    get api_location_labwares_path(location.barcode)
    expect(response).to be_success
    expect(ActiveSupport::JSON.decode(response.body).length).to eq(location.labwares.length)
  end

  it "should retrieve information about a locations audits get api/locations/<barcode>/audits" do
    location = create(:location_with_audits)
    get api_location_audits_path(location.barcode)
    expect(response).to be_success
    expect(ActiveSupport::JSON.decode(response.body).length).to eq(location.audits.length)
  end

  it "should retrieve information about a locations children get api/location/<barcode>/children" do
    location = create(:location_with_children)
    get api_location_children_path(location.barcode)
    expect(response).to be_success
    expect(ActiveSupport::JSON.decode(response.body).length).to eq(location.children.length)
  end

  it "should create a new location" do
    post api_locations_path, user_code: user.swipe_card_id, location: attributes_for(:location)
    expect(response).to be_success
    location = Location.first
    json = ActiveSupport::JSON.decode(response.body)
    expect(json["created_at"]).to eq(location.created_at.to_s(:uk))
    expect(json["updated_at"]).to eq(location.updated_at.to_s(:uk))
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

  it "should return an error if the updated location has invalid attributes" do
    location = create(:location_with_parent)
    location_parent = create(:location)
    patch api_location_path(location.barcode), location: { user_code: user.swipe_card_id, name: nil }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(ActiveSupport::JSON.decode(response.body)["errors"]).not_to be_empty
  end
  
end