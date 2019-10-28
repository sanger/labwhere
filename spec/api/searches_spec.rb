# Provide ability to search via API

require "rails_helper"

RSpec.describe Api::SearchesController, type: :request do
  let!(:location)    { create(:location, name: "A stupid name") }
  let!(:labware)     { create(:labware, barcode: "A stupid barcode", location: create(:location_with_parent)) }

  it "should return the correct results" do
    post api_searches_path, params: { search: { term: "A stupid" } }
    expect(response).to be_successful
    expect(ActiveSupport::JSON.decode(response.body)["count"]).to eq(2)
  end
end
