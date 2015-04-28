require "rails_helper"

RSpec.describe CreateScan, type: :model do

  let!(:location)         { create(:location_with_parent)}
  let(:new_labware)       { build_list(:labware, 4)}
  let(:create_scan)       { CreateScan.new }
  let!(:existing_labware) { create_list(:labware, 4, location: create(:location_with_parent))}

  it "existing location with new labware should create labware and add them to the location" do
    create_scan.submit({"location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes})
    scan = Scan.first
    expect(scan.location).to eq(location)
    expect(scan.labwares.count).to eq(4)
    expect(scan.labwares.all? {|labware| labware.location == location}).to be_truthy
  end

  it "existing location with existing labware should move them to the location" do
    expect{
      create_scan.submit({"location_barcode" => location.barcode, "labware_barcodes" => existing_labware.join_barcodes})
    }.to_not change(Labware, :count)
    scan = Scan.first
    expect(scan.location).to eq(location)
    expect(scan.labwares.count).to eq(4)
    expect(scan.labwares.all? {|labware| labware.location == location}).to be_truthy
  end

  it "existing location with new and existing labware should create them and add or move them to the location" do
    create_scan.submit({"location_barcode" => location.barcode, "labware_barcodes" => (new_labware+existing_labware).join_barcodes})
    scan = Scan.first
    expect(scan.location).to eq(location)
    expect(scan.labwares.count).to eq(8)
    expect(scan.labwares.all? {|labware| labware.location == location}).to be_truthy
  end

  it "no location with existing labware should remove them from the location" do
    create_scan.submit({"labware_barcodes" => existing_labware.join_barcodes})
    scan = Scan.first
    expect(scan.location).to be_nil
    expect(scan.labwares.count).to eq(4)
    expect(scan.labwares.all? {|labware| labware.location.unknown? }).to be_truthy
  end

  it "no location with new labware create labware with no location" do
    create_scan.submit({"labware_barcodes" => new_labware.join_barcodes})
    scan = Scan.first
    expect(scan.location).to be_nil
    expect(scan.labwares.count).to eq(4)
    expect(scan.labwares.all? {|labware| labware.location.unknown? }).to be_truthy
  end

  it "existing location with no parent should not add any type of labware and return an error" do
    orphan_location = create(:location)
    create_scan.submit({"location_barcode" => orphan_location.barcode, "labware_barcodes" => new_labware.join_barcodes})
    expect(Scan.all).to be_empty
    expect(create_scan.errors.full_messages).to include("Location must have a parent")
  end

  it "existing location which is not a container should not add any type of labware and return an error" do
    location.update(container: false)
    create_scan.submit({"location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes
      })
    expect(Scan.all).to be_empty
    expect(create_scan.errors.full_messages).to include("Location must be a container")
  end

  it "existing location which is not active should not add any type of labware and return an error" do
    location.update(status: :inactive)
    create_scan.submit({"location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes})
    expect(Scan.all).to be_empty
    expect(create_scan.errors.full_messages).to include("Location must be active")
  end

  it "location barcode is passed but no location exists should return an error" do
    create_scan.submit({"location_barcode" => "NonexistantBarcode:1", "labware_barcodes" => new_labware.join_barcodes})
    expect(Scan.all).to be_empty
    expect(create_scan.errors.full_messages).to include("Location must exist")
  end

  it "should strip all non ascii characters from the labware barcode" do
    create_scan.submit({"location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes("\r\n")})
    scan = Scan.first
    expect(scan.labwares.count).to eq(4)
    expect(scan.labwares.all? {|labware| !labware.barcode.include?("\r") }).to be_truthy
  end

  
end