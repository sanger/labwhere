# frozen_string_literal: true

# Retrieve location information for a given piece of labware (GET /api/labwares/<barcode>) returns labware object and location object
# Retrieve labwares for a given list of locations barcodes (GET /api/labwares?location_barcodes=<barcode_1>,<barcode_2>...)

require "rails_helper"

RSpec.describe Api::LabwaresController, type: :request do
  let!(:location) { create(:location_with_parent) }
  let!(:labware) { create(:labware_with_audits, location: location) }

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
    let!(:labware_2) { create(:labware_with_audits, location: location_multiple_labware) }
    let!(:labware_3) { create(:labware_with_audits, location: location_multiple_labware) }

    let!(:location_empty) { create(:location_with_parent) }

    let!(:location_single_labware) { create(:location_with_parent) }
    let!(:labware_4) { create(:labware_with_audits, location: location_single_labware) }

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
