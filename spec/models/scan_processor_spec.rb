require "rails_helper"

RSpec.describe ScanProcessor, type: :model do

  let!(:location)         { create(:location_with_parent)}
  let(:new_labware)       { build_list(:labware, 4)}
  let(:scan)              { Scan.new }
  let!(:existing_labware) { create_list(:labware, 4, location: create(:location_with_parent))}

  it "existing location with new labware should create labware and add them to the location" do
    ScanProcessor.new(scan, {"location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes}).save
    scan = Scan.first
    expect(scan.location).to eq(location)
    expect(scan.labwares.count).to eq(4)
    expect(scan.labwares.all? {|labware| labware.location == location}).to be_truthy
  end

  it "existing location with existing labware should move them to the location" do
    expect{
      ScanProcessor.new(scan, {"location_barcode" => location.barcode, "labware_barcodes" => existing_labware.join_barcodes}).save
    }.to_not change(Labware, :count)
    scan = Scan.first
    expect(scan.location).to eq(location)
    expect(scan.labwares.count).to eq(4)
    expect(scan.labwares.all? {|labware| labware.location == location}).to be_truthy
  end

  it "existing location with new and existing labware should create them and add or move them to the location" do
    ScanProcessor.new(scan, {"location_barcode" => location.barcode, "labware_barcodes" => (new_labware+existing_labware).join_barcodes}).save
    scan = Scan.first
    expect(scan.location).to eq(location)
    expect(scan.labwares.count).to eq(8)
    expect(scan.labwares.all? {|labware| labware.location == location}).to be_truthy
  end

  it "no location with existing labware should remove them from the location" do
    ScanProcessor.new(scan, {"labware_barcodes" => existing_labware.join_barcodes}).save
    scan = Scan.first
    expect(scan.location).to be_nil
    expect(scan.labwares.count).to eq(4)
    expect(scan.labwares.all? {|labware| labware.location.unknown? }).to be_truthy
  end

  it "no location with new labware create labware with no location" do
    ScanProcessor.new(scan, {"labware_barcodes" => new_labware.join_barcodes}).save
    scan = Scan.first
    expect(scan.location).to be_nil
    expect(scan.labwares.count).to eq(4)
    expect(scan.labwares.all? {|labware| labware.location.unknown? }).to be_truthy
  end

  it "existing location with no parent should not add any type of labware and return an error" do
    orphan_location = create(:location)
    scan_processor = ScanProcessor.new(scan, {"location_barcode" => orphan_location.barcode, "labware_barcodes" => new_labware.join_barcodes})
    scan_processor.save
    expect(Scan.all).to be_empty
    expect(scan_processor.errors.full_messages).to include("Location must have a parent")
  end

  it "existing location which is not a container should not add any type of labware and return an error" do
    location.update(container: false)
    scan_processor = ScanProcessor.new(scan, {"location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes
      })
    scan_processor.save
    expect(Scan.all).to be_empty
    expect(scan_processor.errors.full_messages).to include("Location must be a container")
  end

  it "existing location which is not active should not add any type of labware and return an error" do
    location.update(active: false)
    scan_processor = ScanProcessor.new(scan, {"location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes})
    scan_processor.save
    expect(Scan.all).to be_empty
    expect(scan_processor.errors.full_messages).to include("Location must be active")
  end

  it "location barcode is passed but no location exists should return an error" do
    scan_processor = ScanProcessor.new(scan, {"location_barcode" => "NonexistantBarcode:1", "labware_barcodes" => new_labware.join_barcodes})
    scan_processor.save
    expect(Scan.all).to be_empty
    expect(scan_processor.errors.full_messages).to include("Location must exist")
  end

  
end