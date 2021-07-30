# frozen_string_literal: true

# Retrieve location information for a given piece of labware (GET /api/labwares/<barcode>) returns labware object and location object
# Retrieve labwares for a given list of locations barcodes (GET /api/labwares?location_barcodes=<barcode_1>,<barcode_2>...)

require "rails_helper"

RSpec.describe Api::LabwaresController, type: :request do
  let!(:location_no_parent)    { create(:location) }
  let!(:location)              { create(:location_with_parent) }
  let!(:labware)               { create(:labware_with_audits, location: location) }
  let!(:locations)             { create_list(:unordered_location_with_parent, 10) }
  let!(:labware_barcode_valid) { "TEST123" }
  let!(:labware_barcode_valid2) { "TEST1234" }

  describe '#create' do
    let!(:guest_user)    { create(:guest) }
    let!(:scientist)     { create(:scientist) }

    context "on success" do
      it "should be a success, when user is valid, location exists and barcode is unique" do
        payload = {
          user_code: scientist.barcode,
          labwares: [
            { location_barcode: locations[0].barcode, labware_barcode: labware_barcode_valid },
            { location_barcode: locations[1].barcode, labware_barcode: labware_barcode_valid2 }
          ]
        }

        expect do
          post api_labwares_path, params: payload
        end.to change(Labware, :count).by(2)

        expect(response).to be_successful
        json = ActiveSupport::JSON.decode(response.body)
        expect(json["message"]).to eq "successful"
      end
    end

    context "on failure" do
      it 'will not be valid without the user barcode filled in' do
        payload = {
          labwares: [
            { location_barcode: locations[0].barcode, labware_barcode: labware_barcode_valid }
          ]
        }
        expect do
          post api_labwares_path, params: payload
        end.to change(Labware, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json["errors"]).not_to be_empty
        expect(json["errors"].length).to eq 1
        expect(json["errors"][0]).to eq "Validation failed: User must exist, User does not exist"
      end

      it 'will not be valid when the user doesnt have permission' do
        payload = {
          user_code: guest_user.barcode,
          labwares: [
            { location_barcode: locations[0].barcode, labware_barcode: labware_barcode_valid },
            { location_barcode: locations[0].barcode, labware_barcode: labware_barcode_valid }
          ]
        }
        expect do
          post api_labwares_path, params: payload
        end.to change(Labware, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json["errors"]).not_to be_empty
        expect(json["errors"].length).to eq 2
        expect(json["errors"][0]).to eq "User does not exist"
        expect(json["errors"][1]).to eq "User is not authorised"
      end

      it "will no be valid when the location does not exist" do
        payload = {
          labwares: [
            { location_barcode: "a invalid location", labware_barcode: labware_barcode_valid }
          ]
        }
        expect do
          post api_labwares_path, params: payload
        end.to change(Labware, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json["errors"]).not_to be_empty
        expect(json["errors"].length).to eq 1
        expect(json["errors"][0]).to eq "location(s) with barcode 'a invalid location' do not exist"
      end

      it "will no be valid when the location does not have a parent" do
        payload = {
          labwares: [
            { location_barcode: location_no_parent.barcode, labware_barcode: labware_barcode_valid }
          ]
        }
        expect do
          post api_labwares_path, params: payload
        end.to change(Labware, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json["errors"]).not_to be_empty
        expect(json["errors"].length).to eq 1
        expect(json["errors"][0]).to eq "Validation failed: Location does not have a parent"
      end

      it 'will not be valid without a file selected' do
        # create_upload_labware.submit(params.merge(upload_labware_form:
        #   { 'user_code' => scientist.barcode }))
        # expect(create_upload_labware.errors.full_messages).to include('The required fields must be filled in')
      end

      it 'will not be valid without a valid user' do
        # create_upload_labware.submit(params.merge(upload_labware_form:
        #   { 'user_code' => 'dummy_user_code', 'file' => file_param }))
        # expect(create_upload_labware.errors.full_messages).to include("User #{I18n.t('errors.messages.existence')}")
      end

      it 'will not be valid with the wrong format of file' do
        # create_upload_labware.submit(params.merge(upload_labware_form:
        #   { 'user_code' => scientist.barcode, 'file' => 'dummy_file' }))
        # expect(create_upload_labware.errors.full_messages).to include('File must be a csv.')
      end

      # when barcode is not unique
      # when one barcode in the list fails, duplicate second labware barcode
    end
  end

  describe '#show' do
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

  describe '#index' do
    let!(:location_multiple_labware) { location }
    let!(:labware2) { create(:labware_with_audits, location: location_multiple_labware) }
    let!(:labware3) { create(:labware_with_audits, location: location_multiple_labware) }

    let!(:location_empty) { create(:location_with_parent) }

    let!(:location_single_labware) { create(:location_with_parent) }
    let!(:labware4) { create(:labware_with_audits, location: location_single_labware) }

    let!(:location_barcodes_params) do
      {
        'location_barcodes' => "#{location_multiple_labware.barcode},#{location_empty.barcode},#{location_single_labware.barcode}",
        'controller' => 'api/labwares',
        'action' => 'index'
      }
    end

    context 'with location barcodes parameter' do
      before(:each) do
        get api_labwares_path(location_barcodes_params)
        @json = ActiveSupport::JSON.decode(response.body)
      end

      it "should be a success" do
        expect(response).to be_successful
      end

      it "should return all labwares" do
        expect(@json.size).to eq(4)
      end

      it "should return labware barcodes" do
        expect(@json[0]["barcode"]).to_not be_nil
      end

      it "should return location object associated with labware" do
        expect(@json[0]["location"]).to_not be_empty
      end
    end

    context 'with no parameters' do
      before(:each) do
        get api_labwares_path(labware.barcode)
        @json = ActiveSupport::JSON.decode(response.body)
      end

      it 'should not return a body' do
        expect(@json).to be_nil
      end
    end
  end

  context 'by_barcode' do
    let!(:labwares) { create_list(:labware_with_location, 10) }
    let!(:barcodes) { labwares.pluck(:barcode).sample(5) }

    context 'when all of the labwares have locations' do
      before(:each) do
        post api_labwares_by_barcode_path, params: { barcodes: barcodes }
        @json = ActiveSupport::JSON.decode(response.body)
      end

      it 'should produce some json' do
        expect(@json.length).to eq(5)

        labware = @json.first
        expect(labware["barcode"]).to_not be_empty
        expect(labware["location_barcode"]).to_not be_empty
      end
    end

    context 'when one of the labwares have no location' do
      let!(:labware) { create(:labware) }
      let!(:barcode) { labware.barcode }

      before(:each) do
        post api_labwares_by_barcode_path, params: { barcodes: barcodes + [barcode] }
        @json = ActiveSupport::JSON.decode(response.body)
      end

      it 'should produce some json' do
        expect(@json.length).to eq(6)

        labware = @json.find { |l| l["barcode"] == barcode }

        expect(labware["barcode"]).to be_present
        expect(labware["location_barcode"]).to_not be_present
      end
    end

    context 'when known locations query parameter set' do
      let!(:labware_unknown_location) { create(:labware, location: UnknownLocation.get) }
      let!(:labware_null_location) { create(:labware, location: nil) }
      let!(:barcode_unknown_location) { labware_unknown_location.barcode }
      let!(:barcode_null_location) { labware_null_location.barcode }

      before(:each) do
        post api_labwares_by_barcode_path, params: { barcodes: barcodes + [barcode_null_location, barcode_unknown_location], known: "true" }
        @json = ActiveSupport::JSON.decode(response.body)
      end

      it 'should produce some json' do
        expect(@json.length).to eq(5)
      end

      it 'should not return labwares at the unknown location' do
        labware = @json.find { |l| l["barcode"] == barcode_unknown_location }
        expect(labware).to be_falsy
      end

      it 'should not return labwares with null locations' do
        labware = @json.find { |l| l["barcode"] == barcode_null_location }
        expect(labware).to be_falsy
      end
    end
  end
end
