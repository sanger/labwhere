# frozen_string_literal: true

require "rails_helper"

RSpec.describe LocationScanForm, type: :model do
  let(:create_location_scan)  { LocationScanForm.new }
  let!(:user)                 { create(:scientist) }
  let(:params)                { ActionController::Parameters.new(controller: "location_scans", action: "create") }
  let(:child_locations)       { create_list(:location_with_parent, 5) }
  let!(:parent_location)      { create(:location_with_parent) }

  it "will not be valid without a valid user" do
    create_location_scan.submit(params.merge(location_scan_form:
      { "parent_location_barcode" => parent_location.barcode, "child_location_barcodes" => child_locations.join_barcodes }))
    expect(create_location_scan.errors.full_messages).to include("User #{I18n.t("errors.messages.existence")}")
  end

  it "will not be valid without a location" do
    create_location_scan.submit(params.merge(location_scan_form:
      { "parent_location_barcode" => 'lw-no-location-here', "child_location_barcodes" => child_locations.join_barcodes, "user_code" => user.swipe_card_id }))
    expect(create_location_scan.errors.full_messages).to include("Parent location #{I18n.t("errors.messages.existence")}")
  end

  it "will not be valid unless all of the child locations exist" do
    create_location_scan.submit(params.merge(location_scan_form:
      { "parent_location_barcode" => parent_location.barcode, "child_location_barcodes" => child_locations.join_barcodes + "\nlw-no-location-here", "user_code" => user.swipe_card_id }))
    expect(create_location_scan.errors.full_messages).to include("Location with barcode lw-no-location-here #{I18n.t("errors.messages.existence")}")
  end

  it "when valid will make add all locations to parent" do
    create_location_scan.submit(params.merge(location_scan_form:
      { "parent_location_barcode" => parent_location.barcode, "child_location_barcodes" => child_locations.join_barcodes, "user_code" => user.swipe_card_id }))
    child_locations.each do |location|
      location.reload
      expect(location.parent).to eq(parent_location)
      expect(parent_location.children).to include(location)
    end
  end

end
