require "rails_helper"

RSpec.describe ScanForm, type: :model do
  let(:create_scan) { ScanForm.new }
  let!(:user) { create(:scientist) }
  let(:params)              { ActionController::Parameters.new(controller: "scans", action: "create") }
  let(:new_labware)         { build_list(:labware, 4) }
  let!(:existing_location)  { create(:location_with_parent) }
  let!(:existing_labware)   { create_list(:labware, 4, location: existing_location) }

  it "should reject creation of the scan if the user is unknown" do
    create_scan.submit(params.merge(scan:
      { "location_barcode" => "NonexistantBarcode:1", "labware_barcodes" => new_labware.join_barcodes }))
    expect(create_scan.errors.full_messages).to include("User #{I18n.t("errors.messages.existence")}")
  end

  context "unordered location" do
    let!(:location)           { create(:unordered_location_with_parent) }
    let!(:existing_location)  { create(:unordered_location_with_parent) }

    it "existing location with new labware should create labware and add them to the location" do
      create_scan.submit(params.merge(scan:
        { "location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes, user_code: user.swipe_card_id }))
      scan = Scan.first
      expect(scan.user).to eq(user)
      expect(scan.location).to eq(location)
      expect(scan.location.labwares.count).to eq(4)
      expect(scan.location.labwares.all? { |labware| labware.location == location }).to be_truthy
    end

    it "existing location with existing labware should move them to the location" do
      expect {
        create_scan.submit(params.merge(scan:
         { "location_barcode" => location.barcode, "labware_barcodes" => existing_labware.join_barcodes, user_code: user.swipe_card_id }))
      }.to_not change(Labware, :count)
      scan = Scan.first
      expect(scan.user).to eq(user)
      expect(scan.location).to eq(location)
      expect(scan.location.labwares.count).to eq(4)
      expect(scan.location.labwares.all? { |labware| labware.location == location }).to be_truthy
    end

    it "existing location with new and existing labware should create them and add or move them to the location" do
      create_scan.submit(params.merge(scan:
        { "location_barcode" => location.barcode, "labware_barcodes" => (new_labware + existing_labware).join_barcodes, user_code: user.swipe_card_id }))
      scan = Scan.first
      expect(scan.location).to eq(location)
      expect(scan.location.labwares.count).to eq(8)
      expect(scan.location.labwares.all? { |labware| labware.location == location }).to be_truthy
    end

    it "should produce an audit record for each labware" do
      create_scan.submit(params.merge(scan:
       { "location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes, user_code: user.swipe_card_id }))
      expect(Audit.all.count).to eq(4)
      expect(location.labwares.first.audits.first.user).to eq(user)
      expect(location.labwares.first.audits.first.action).to eq("create")
    end
  end

  context "ordered location" do
    let!(:location)           { create(:ordered_location_with_parent, rows: 5, columns: 5) }

    it "will fill coordinates with labwares if there are enough available coordinates" do
      create_scan.submit(params.merge(scan:
        { "location_barcode" => location.barcode, "labware_barcodes" => (new_labware + existing_labware).join_barcodes, start_position: 5, user_code: user.swipe_card_id }))
      scan = Scan.first
      expect(scan.location.labwares.count).to eq(8)
      expect(scan.location.coordinates.filled.count).to eq(8)
    end

    it "will return an error if there are not enough available coordinates" do
      create_scan.submit(params.merge(scan:
        { "location_barcode" => location.barcode, "labware_barcodes" => (new_labware + existing_labware).join_barcodes, start_position: 25, user_code: user.swipe_card_id }))
      expect(create_scan.errors.full_messages).to include("#{I18n.t("errors.messages.not_enough_empty_coordinates")}")
    end
  end

  context "no location" do
    it "no location with existing labware should remove them from the location" do
      create_scan.submit(params.merge(scan:
        { "labware_barcodes" => existing_labware.join_barcodes, user_code: user.swipe_card_id }))
      scan = Scan.first
      expect(scan.location).to be_unknown
      expect(scan.location.labwares.count).to eq(4)
      expect(scan.location.labwares.all? { |labware| labware.location.unknown? }).to be_truthy
    end

    it "no location with new labware should create labware with no location" do
      create_scan.submit(params.merge(scan:
        { "labware_barcodes" => new_labware.join_barcodes, user_code: user.swipe_card_id }))
      scan = Scan.first
      expect(scan.location).to be_unknown
      expect(scan.location.labwares.count).to eq(4)
      expect(scan.location.labwares.all? { |labware| labware.location.unknown? }).to be_truthy
    end
  end

  context "invalid location" do
    let!(:location) { create(:location_with_parent) }

    it "existing location with no parent should not add any type of labware and return an error" do
      orphan_location = create(:location)
      create_scan.submit(params.merge(
                           scan: { "location_barcode" => orphan_location.barcode, "labware_barcodes" => new_labware.join_barcodes, user_code: user.swipe_card_id }
                         ))
      expect(Scan.all).to be_empty
      expect(location.labwares).to be_empty
      expect(create_scan.errors.full_messages).to include("Location #{I18n.t("errors.messages.nested")}")
    end

    it "existing location which is not a container should not add any type of labware and return an error" do
      location.update(container: false)
      create_scan.submit(params.merge(scan:
        { "location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes, user_code: user.swipe_card_id }))
      expect(Scan.all).to be_empty
      expect(location.labwares).to be_empty
      expect(create_scan.errors.full_messages).to include("Location #{I18n.t("errors.messages.container")}")
    end

    it "existing location which is not active should not add any type of labware and return an error" do
      location.update(status: :inactive)
      create_scan.submit(params.merge(scan:
        { "location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes, user_code: user.swipe_card_id }))
      expect(Scan.all).to be_empty
      expect(location.labwares).to be_empty
      expect(create_scan.errors.full_messages).to include("Location #{I18n.t("errors.messages.active")}")
    end

    it "location barcode is passed but no location exists should return an error" do
      create_scan.submit(params.merge(scan:
        { "location_barcode" => "NonexistantBarcode:1", "labware_barcodes" => new_labware.join_barcodes, user_code: user.swipe_card_id }))
      expect(create_scan.errors.full_messages).to include("Location #{I18n.t("errors.messages.existence")}")
      expect(Scan.all).to be_empty
    end
  end
end
