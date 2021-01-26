# frozen_string_literal: true

# Allow one or more pieces of labware to be scanned in or out of a location via the API (POST api/scans)

require "rails_helper"

RSpec.describe Api::ScansController, type: :request do
  let(:new_labware) { build_list(:labware, 4) }
  let!(:sci_swipe_card_id) { generate(:swipe_card_id) }
  let!(:scientist) { create(:scientist, swipe_card_id: sci_swipe_card_id) }
  let!(:existing_labware) { create(:labware, location: create(:location_with_parent)) }

  it "should be able to scan some labware in using barcodes via post api/scans" do
    location = create(:unordered_location_with_parent)
    post api_scans_path, params: { scan: { location_barcode: location.barcode, labware_barcodes: new_labware.join_barcodes, user_code: sci_swipe_card_id } }
    expect(response).to be_successful
    json = ActiveSupport::JSON.decode(response.body)
    expect(json["message"]).to eq(Scan.first.message)
    expect(json["location"]["id"]).to eq(location.id)
  end

  it "should return an error if the scan is incorrect" do
    post api_scans_path, params: { scan: { location_barcode: "999999:1", labware_barcodes: new_labware.join_barcodes, user_code: sci_swipe_card_id } }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(ActiveSupport::JSON.decode(response.body)["errors"]).not_to be_empty
  end

  it "should return an error if the user is not authorised" do
    location = create(:location)
    post api_scans_path, params: { scan: { location_barcode: location.barcode, labware_barcodes: new_labware.join_barcodes } }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(ActiveSupport::JSON.decode(response.body)["errors"]).not_to be_empty
  end
end
