# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::CoordinatesController, type: :request do
  describe "#index" do
    before(:each) do
      get api_location_coordinates_path(location.barcode)
      @body = ActiveSupport::JSON.decode(response.body)
    end

    context "when location has no coordinates" do
      let(:location) { create(:unordered_location_with_parent) }

      it "is successful" do
        expect(response).to be_successful
      end

      it "returns an empty array" do
        expect(@body).to eq([])
      end
    end

    context "when location has coordinates" do
      let(:location) { create(:ordered_location_with_parent) }

      it "is successful" do
        expect(response).to be_successful
      end

      it "lists the coordinates" do
        expect(@body).to be_a_kind_of(Array)
        expect(@body.length).to eql(location.coordinates.size)
      end
    end
  end

  describe "#update" do
    let(:uri_params) do
      {
        location_barcode: location.barcode,
        id: location.coordinates.first.id
      }
    end
    let(:location) { create(:ordered_location_with_parent) }
    let(:administrator) { create(:administrator) }
    let(:params) do
      {
        coordinate: {
          labware_barcode: labware_barcode,
          user_code: administrator.login
        }
      }
    end

    before(:each) do
      patch api_location_coordinate_path(uri_params), params: params
      @body = ActiveSupport::JSON.decode(response.body)
    end

    context "when no barcode is provided" do
      let(:params) {
        { coordinate: {
          user_code: administrator.login
        } }
      }

      it "is not successful" do
        expect(response).to_not be_successful
      end

      it "returns an error" do
        expect(@body["errors"]).to include("A labware barcode must be provided")
      end
    end

    context "when barcode is nil" do
      let(:labware_barcode) { nil }

      it "is successful" do
        expect(response).to be_successful
      end

      it "removes labware from the coordinate" do
        expect(@body["labware"]).to eql("Empty")
        expect(location.coordinates.first.reload.labware).to be_instance_of(NullLabware)
      end
    end

    context "when barcode is set" do
      let(:labware_barcode) { build(:labware).barcode }

      it "is successful" do
        expect(response).to be_successful
      end

      it "fills the coordinate with the labware" do
        expect(@body["labware"]).to eql(labware_barcode)
      end
    end
  end

  describe "bulk #update" do
    let(:coordinates) { create_list(:coordinate, 5) }
    let(:coordinate_params) { coordinates.map.with_index { |coordinate, i| { id: coordinate.id, labware_barcode: labwares[i].barcode } } }
    let(:administrator) { create(:administrator) }
    let(:labwares) { create_list(:labware, 5) }

    before :each do
      put api_coordinates_path(params)
      @body = ActiveSupport::JSON.decode(response.body)
    end

    context "when all inputs are valid" do
      let(:params) { { user_code: administrator.login, coordinates: coordinate_params } }

      it "is successful" do
        expect(response).to be_successful
      end

      it "updates all the coordinates" do
        coordinates.each_with_index { |coordinate, i| expect(coordinate.reload.labware).to eq(labwares[i]) }
      end
    end

    context "when any inputs are invalid" do
      let(:bad_param) { { id: 99999999, labware_barcode: "ledzep" } }
      let(:params) { { user_code: administrator.login, coordinates: coordinate_params.push(bad_param) } }

      it "is unsuccessful" do
        expect(response).to_not be_successful
      end

      it "doesn't update any of the coordinates" do
        coordinates.each { |coordinate| expect(coordinate.reload.labware).to be_instance_of(NullLabware) }
      end
    end
  end
end
