require "rails_helper"

RSpec.describe ScanForm, type: :model do

  let!(:location)           { create(:location_with_parent)}
  let!(:existing_location)  { create(:location_with_parent)}
  let(:new_labware)         { build_list(:labware, 4)}
  let(:create_scan)         { ScanForm.new }
  let!(:existing_labware)   { create_list(:labware, 4, location: existing_location)}
  let!(:user)               { create(:standard)}
  let(:params)              { ActionController::Parameters.new(controller: "scans", action: "create")}

  it "existing location with new labware should create labware and add them to the location" do
    create_scan.submit(params.merge(scan: 
      {"location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes, user_code: user.swipe_card_id}))
    scan = Scan.first
    expect(scan.user).to eq(user)
    expect(scan.location).to eq(location)
    expect(scan.labwares.count).to eq(4)
    expect(scan.labwares.all? {|labware| labware.location == location}).to be_truthy
  end

  it "existing location with existing labware should move them to the location" do
    expect{create_scan.submit(params.merge(scan:
        {"location_barcode" => location.barcode, "labware_barcodes" => existing_labware.join_barcodes, user_code: user.swipe_card_id}))
    }.to_not change(Labware, :count)
    scan = Scan.first
    expect(scan.user).to eq(user)
    expect(scan.location).to eq(location)
    expect(scan.labwares.count).to eq(4)
    expect(scan.labwares.all? {|labware| labware.location == location}).to be_truthy
  end

  it "existing location with new and existing labware should create them and add or move them to the location" do
    create_scan.submit(params.merge(scan:
      {"location_barcode" => location.barcode, "labware_barcodes" => (new_labware+existing_labware).join_barcodes, user_code: user.swipe_card_id}))
    scan = Scan.first
    expect(scan.location).to eq(location)
    expect(scan.labwares.count).to eq(8)
    expect(scan.labwares.all? {|labware| labware.location == location}).to be_truthy
  end

  it "no location with existing labware should remove them from the location" do
    create_scan.submit(params.merge(scan:
      {"labware_barcodes" => existing_labware.join_barcodes, user_code: user.swipe_card_id}))
    scan = Scan.first
    expect(scan.location).to be_unknown
    expect(scan.labwares.count).to eq(4)
    expect(scan.labwares.all? {|labware| labware.location.unknown? }).to be_truthy
  end

  it "no location with new labware should create labware with no location" do
    create_scan.submit(params.merge(scan:
      {"labware_barcodes" => new_labware.join_barcodes, user_code: user.swipe_card_id}))
    scan = Scan.first
    expect(scan.location).to be_unknown
    expect(scan.labwares.count).to eq(4)
    expect(scan.labwares.all? {|labware| labware.location.unknown? }).to be_truthy
  end

  it "existing location with no parent should not add any type of labware and return an error" do
    orphan_location = create(:location)
    create_scan.submit(params.merge(
      scan:{"location_barcode" => orphan_location.barcode, "labware_barcodes" => new_labware.join_barcodes, user_code: user.swipe_card_id}))
    expect(Scan.all).to be_empty
    expect(create_scan.errors.full_messages).to include("Location #{I18n.t("errors.messages.nested")}")
  end

  it "existing location which is not a container should not add any type of labware and return an error" do
    location.update(container: false)
    create_scan.submit(params.merge(scan:
      {"location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes, user_code: user.swipe_card_id}))
    expect(Scan.all).to be_empty
    expect(create_scan.errors.full_messages).to include("Location #{I18n.t("errors.messages.container")}")
  end

  it "existing location which is not active should not add any type of labware and return an error" do
    location.update(status: :inactive)
    create_scan.submit(params.merge(scan:
      {"location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes, user_code: user.swipe_card_id}))
    expect(Scan.all).to be_empty
    expect(create_scan.errors.full_messages).to include("Location #{I18n.t("errors.messages.active")}")
  end

  it "location barcode is passed but no location exists should return an error" do
    create_scan.submit(params.merge(scan: 
      {"location_barcode" => "NonexistantBarcode:1", "labware_barcodes" => new_labware.join_barcodes, user_code: user.swipe_card_id}))
    expect(create_scan.errors.full_messages).to include("Location #{I18n.t("errors.messages.existence")}")
    expect(Scan.all).to be_empty
  end

  it "should strip all non ascii characters from the labware barcode" do
    create_scan.submit(params.merge(scan: 
      {"location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes("\r\n"), user_code: user.swipe_card_id}))
    scan = Scan.first
    expect(scan.labwares.count).to eq(4)
    expect(scan.labwares.all? {|labware| !labware.barcode.include?("\r") }).to be_truthy
  end

  it "should reject creation of the scan if the user is unknown" do
     create_scan.submit(params.merge(scan: 
      {"location_barcode" => "NonexistantBarcode:1", "labware_barcodes" => new_labware.join_barcodes}))
    expect(create_scan.errors.full_messages).to include("User #{I18n.t("errors.messages.existence")}")
  end

end