# frozen_string_literal: true

# As a LIMS developer I want to be able to access the functionality of LabWhere via a RESTful API in order to integrate LIMS with it.
# Create locations
require "rails_helper"

RSpec.describe Api::LocationsController, type: :request do
  let!(:admin_swipe_card_id) { generate(:swipe_card_id) }
  let!(:administrator) { create(:administrator, swipe_card_id: admin_swipe_card_id) }

  it 'has a uuid after creation' do
    expect(create(:location).uuid).to be_present
  end

  it "should retrieve information about locations get /api/locations" do
    location_type = create(:location_type, name: "Building")
    locations = create_list(:location, 5, location_type: location_type)
    get api_locations_path
    expect(response).to be_successful
    expect(ActiveSupport::JSON.decode(response.body).length).to eq(locations.length)
  end

  it "locations should not include location unknown" do
    locations = create_list(:location, 5)
    location_unknown = UnknownLocation.get
    get api_locations_path
    expect(response.body).to_not include(location_unknown.name)
  end

  it "should return null for parent if location does not have a parent" do
    location = create(:location)
    get api_location_path(location.barcode)
    expect(response).to be_successful
    json = ActiveSupport::JSON.decode(response.body)
    expect(json["parent"]).to eq("Empty")
  end

  it "should retrieve information about a location get /api/locations/<barcode>" do
    location = create(:location_with_parent)
    get api_location_path(location.barcode)
    expect(response).to be_successful
    json = ActiveSupport::JSON.decode(response.body)
    expect(json["id"]).to eq(location.id)
    expect(json["name"]).to eq(location.name)
    expect(json["barcode"]).to eq(location.barcode)
    expect(json["parent"]).to eq(api_location_path(location.parent.barcode))
    expect(json["container"]).to eq(location.container)
    expect(json["status"]).to eq(location.status)
    expect(json["location_type_id"]).to eq(location.location_type_id)
    expect(json["created_at"]).to eq(location.created_at.to_s(:uk))
    expect(json["updated_at"]).to eq(location.updated_at.to_s(:uk))
    expect(json["parentage"]).to eq(location.parentage)
    expect(json["rows"]).to eq(location.rows)
    expect(json["columns"]).to eq(location.columns)
  end

  it "ordered location should store information about coordinates" do
    location = create(:ordered_location_with_parent)
    get api_location_path(location.barcode)
    expect(response).to be_successful
    json = ActiveSupport::JSON.decode(response.body)
    expect(json["coordinates"].length).to eq(location.coordinates.count)
  end

  it "should retrieve information about a locations audits get api/locations/<barcode>/audits" do
    location = create(:location_with_audits)
    get api_location_audits_path(location.barcode)
    expect(response).to be_successful
    expect(ActiveSupport::JSON.decode(response.body).length).to eq(location.audits.length)
  end

  it "should retrieve information about a locations labwares get api/locations/<barcode>/labwares" do
    location = create(:unordered_location_with_labwares)
    get api_location_labwares_path(location.barcode)
    expect(response).to be_successful
    expect(ActiveSupport::JSON.decode(response.body).length).to eq(location.labwares.length)
  end

  it "should retrieve information about a locations children get api/location/<barcode>/children" do
    location = create(:unordered_location_with_children)
    get api_location_children_path(location.barcode)
    expect(response).to be_successful
    expect(ActiveSupport::JSON.decode(response.body).length).to eq(location.children.length)
  end

  it "unordered location should contain a link to labwares and children" do
    location = create(:unordered_location)
    get api_location_path(location.barcode)
    json = ActiveSupport::JSON.decode(response.body)
    expect(json["labwares"]).to eq(api_location_labwares_path(location.barcode))
    expect(json["children"]).to eq(api_location_children_path(location.barcode))
  end

  it "ordered location should contain its coordinates with labware barcode" do
    location = create(:ordered_location_with_labwares)
    get api_location_path(location.barcode)
    json = ActiveSupport::JSON.decode(response.body)
    coordinates = json["coordinates"]
    expect(coordinates.length).to eq(location.coordinates.count)
    expect(coordinates.first["position"]).to eq(location.coordinates.first.position)
    expect(coordinates.first["row"]).to eq(location.coordinates.first.row)
    expect(coordinates.first["column"]).to eq(location.coordinates.first.column)
    expect(coordinates.first["labware"]).to eq(location.coordinates.first.labware.barcode)
    expect(coordinates.first["location"]).to eq(location.coordinates.first.location.barcode)
  end

  it "should create a new location" do
    post api_locations_path, params: { location: attributes_for(:location).merge(user_code: admin_swipe_card_id) }
    expect(response).to be_successful
    location = Location.first
    json = ActiveSupport::JSON.decode(response.body)
    expect(json["created_at"]).to eq(location.created_at.to_s(:uk))
    expect(json["updated_at"]).to eq(location.updated_at.to_s(:uk))
  end

  it "should return an error if the location has invalid attributes" do
    post api_locations_path, params: { location: attributes_for(:location).except(:name).merge(user_code: admin_swipe_card_id) }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(ActiveSupport::JSON.decode(response.body)["errors"]).not_to be_empty
  end

  it "should return an error if the user is invalid" do
    post api_locations_path, params: { location: attributes_for(:location) }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(ActiveSupport::JSON.decode(response.body)["errors"]).not_to be_empty
  end

  it "should update an existing location" do
    location = create(:location_with_parent)
    location_parent = create(:location)
    patch api_location_path(location.barcode), params: { location: { user_code: admin_swipe_card_id, parent_id: location_parent.id } }
    expect(response).to be_successful
    expect(location.reload.parent).to eq(location_parent)
  end

  it "should return an error if the updated location has invalid attributes" do
    location = create(:location_with_parent)
    location_parent = create(:location)
    patch api_location_path(location.barcode), params: { location: { user_code: admin_swipe_card_id, name: nil } }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(ActiveSupport::JSON.decode(response.body)["errors"]).not_to be_empty
  end
end
