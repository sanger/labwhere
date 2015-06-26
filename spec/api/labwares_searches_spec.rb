require "rails_helper"

RSpec.describe Api::Labwares::SearchesController, type: :request do

  let!(:location) { create(:location_with_parent)}
  let!(:labwares) { create_list(:labware, 5, location: location)}

  before(:each) do
    post api_labwares_searches_path, barcodes: Labware.pluck(:barcode)
  end

  it "should be a success" do
    expect(response).to be_success
  end

  it "should return the labwares" do
    json = ActiveSupport::JSON.decode(response.body)
    expect(json.length).to eq(5)
    Labware.pluck(:barcode).each do |barcode|
      expect(response.body).to include(barcode)
    end
    expect(json.first["location"]["barcode"]).to eq(location.barcode)
  end
end