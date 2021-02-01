# frozen_string_literal: true

# As a LIMS developer I want to be able to access the functionality of LabWhere via a RESTful API in order to integrate LIMS with it.
# Create location types
require "rails_helper"

RSpec.describe Api::LocationTypesController, type: :request do
  let!(:admin_swipe_card_id) { generate(:swipe_card_id) }
  let!(:administrator) { create(:administrator, swipe_card_id: admin_swipe_card_id) }

  it "should retrieve information about location types get /api/location_types" do
    location_types = create_list(:location_type, 5)
    get api_location_types_path
    expect(response).to be_successful
    expect(ActiveSupport::JSON.decode(response.body).length).to eq(location_types.length)
  end

  it "should retrieve information about a location type get /api/location_types/<id>" do
    location_type = create(:location_type)
    get api_location_type_path(location_type)
    expect(response).to be_successful
    json = ActiveSupport::JSON.decode(response.body)
    expect(json["id"]).to eq(location_type.id)
    expect(json["name"]).to eq(location_type.name)
    expect(json["created_at"]).to eq(location_type.created_at.to_s(:uk))
    expect(json["updated_at"]).to eq(location_type.updated_at.to_s(:uk))
    expect(json["locations"]).to eq(api_location_type_locations_path(location_type))
    expect(json["audits"]).to eq(api_location_type_audits_path(location_type))
  end

  it "should retrieve information about a location types location get /api/location_types/<id>/locations" do
    location_type = create(:location_type_with_locations)
    get api_location_type_locations_path(location_type)
    expect(response).to be_successful
    expect(ActiveSupport::JSON.decode(response.body).length).to eq(location_type.locations.length)
  end

  it "should retrieve information about a location types audits get /api/location_types/<id>/audits" do
    location_type = create(:location_type_with_audits)
    get api_location_type_audits_path(location_type)
    expect(response).to be_successful
    expect(ActiveSupport::JSON.decode(response.body).length).to eq(location_type.audits.length)
  end

  it "should create a new location type" do
    post api_location_types_path, params: { location_type: attributes_for(:location_type).merge(user_code: admin_swipe_card_id) }
    location_type = LocationType.first
    expect(response).to be_successful
    json = ActiveSupport::JSON.decode(response.body)
    expect(json["created_at"]).to eq(location_type.created_at.to_s(:uk))
    expect(json["updated_at"]).to eq(location_type.updated_at.to_s(:uk))
    expect(json["locations"]).to eq(api_location_type_locations_path(location_type))
    expect(json["audits"]).to eq(api_location_type_audits_path(location_type))
  end

  it "should return an error if the location type has invalid attributes" do
    post api_location_types_path, params: { location_type: attributes_for(:location_type).except(:name).merge(user_code: admin_swipe_card_id) }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(ActiveSupport::JSON.decode(response.body)["errors"]).not_to be_empty
  end

  it "should return an error if the user is invalid" do
    post api_location_types_path, params: { location_type: attributes_for(:location_type) }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(ActiveSupport::JSON.decode(response.body)["errors"]).not_to be_empty
  end

  it "should update an existing location type" do
    location_type = create(:location_type)
    location_type_new = build(:location_type)
    patch api_location_type_path(location_type), params: { location_type: { user_code: admin_swipe_card_id, name: location_type_new.name } }
    expect(response).to be_successful
    expect(location_type.reload.name).to eq(location_type_new.name)
  end

  it "should return an error if the updated location type has invalid attributes" do
    location_type_1 = create(:location_type)
    location_type_2 = create(:location_type)
    patch api_location_type_path(location_type_1), params: { location_type: { user_code: admin_swipe_card_id, name: location_type_2.name } }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(ActiveSupport::JSON.decode(response.body)["errors"]).not_to be_empty
  end
end
