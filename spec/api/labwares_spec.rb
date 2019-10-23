#Retrieve location information for a given piece of labware (GET /api/labwares/<barcode>) returns labware object and location object

require "rails_helper"

RSpec.describe Api::LabwaresController, type: :request do 

 let!(:location)  { create(:location_with_parent)}
 let!(:labware)   { create(:labware_with_audits, location: location)}

 before(:each) do
  get api_labware_path(labware.barcode)
  @json = ActiveSupport::JSON.decode(response.body)
 end

 it "should be a success" do
  expect(response).to be_successful
 end

 it "should return labware barcode" do
  expect(@json["barcode"]).to eq(labware.barcode)
 end

 it "should return location object associated with labware" do
  expect(@json["location"]).to_not be_empty
 end

 it "should return link to labware audits" do
  expect(@json["audits"]).to eq(api_labware_audits_path(labware.barcode))
 end

 it "link to labware audits should return audits for labware" do
  get @json["audits"]
  expect(response).to be_successful
  json = ActiveSupport::JSON.decode(response.body).first
  audit = labware.audits.first
  expect(json["user"]).to eq(audit.user.login)
  expect(json["created_at"]).to eq(audit.created_at.to_s(:uk))
 end

end