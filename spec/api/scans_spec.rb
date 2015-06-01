#Allow one or more pieces of labware to be scanned in or out of a location via the API (POST api/scans) 

require "rails_helper"

RSpec.describe Api::ScansController, type: :request do 

  let!(:location)           { create(:location_with_parent)}
  let(:new_labware)         { build_list(:labware, 4)}
  let!(:user)               { create(:standard)}

  it "should be able to scan some labware in via post api/scans" do
    post api_scans_path, scan: { location_barcode: location.barcode, labware_barcodes: new_labware.join_barcodes, user_code: user.swipe_card_id }
    expect(response).to be_success
    expect(ActiveSupport::JSON.decode(response.body)["message"]).to eq(Scan.first.message)
  end

  it "should return an error if the scan is incorrect" do
    post api_scans_path, scan: { location_barcode: "999999:1", labware_barcodes: new_labware.join_barcodes, user_code: user.swipe_card_id }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(ActiveSupport::JSON.decode(response.body)["errors"]).not_to be_empty
  end

  it "should return an error if the user is not authorised" do
    post api_scans_path, scan: { location_barcode: location.barcode, labware_barcodes: new_labware.join_barcodes }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(ActiveSupport::JSON.decode(response.body)["errors"]).not_to be_empty
  end
end