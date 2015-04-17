require 'rails_helper'

describe ScanForm do

  let!(:location)         { create(:location_with_parent)}
  let(:scan_form)         { ScanForm.new}
  let(:new_labware)       { build_list(:labware, 4)}
  let!(:existing_labware) { create_list(:labware, 4, location: create(:location_with_parent))}

  it "should be able to add some fields" do
    scan_form.location_barcode = "A barcode"
    scan_form.labware_barcodes = "Some barcodes"
    expect(scan_form.location_barcode).to eq("A barcode")
    expect(scan_form.labware_barcodes).to eq("Some barcodes")
  end

  it "existing location with new labware should create labware and add them to the location" do
    scan_form.submit({"location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes})
    scan = Scan.first
    expect(scan.location).to eq(location)
    expect(scan.labwares.count).to eq(4)
    expect(scan.labwares.all? {|labware| labware.location == location}).to be_truthy
  end

  it "existing location with existing labware should move them to the location" do
    expect{
      scan_form.submit({"location_barcode" => location.barcode, "labware_barcodes" => existing_labware.join_barcodes})
    }.to_not change(Labware, :count)
    scan = Scan.first
    expect(scan.location).to eq(location)
    expect(scan.labwares.count).to eq(4)
    expect(scan.labwares.all? {|labware| labware.location == location}).to be_truthy
  end

  it "existing location with new and existing labware should create them and add or move them to the location" do
    scan_form.submit({"location_barcode" => location.barcode, "labware_barcodes" => (new_labware+existing_labware).join_barcodes})
    scan = Scan.first
    expect(scan.location).to eq(location)
    expect(scan.labwares.count).to eq(8)
    expect(scan.labwares.all? {|labware| labware.location == location}).to be_truthy
  end

  it "no location with existing labware should remove them from the location" do
    scan_form.submit({"labware_barcodes" => existing_labware.join_barcodes})
    scan = Scan.first
    expect(scan.location).to be_nil
    expect(scan.labwares.count).to eq(4)
    expect(scan.labwares.all? {|labware| labware.location.unknown? }).to be_truthy
  end

  it "no location with new labware create labware with no location" do
    scan_form.submit({"labware_barcodes" => new_labware.join_barcodes})
    scan = Scan.first
    expect(scan.location).to be_nil
    expect(scan.labwares.count).to eq(4)
    expect(scan.labwares.all? {|labware| labware.location.unknown? }).to be_truthy
  end

  it "existing location with no parent should not add any type of labware and return an error" do
    orphan_location = create(:location)
    scan_form.submit({"location_barcode" => orphan_location.barcode, "labware_barcodes" => new_labware.join_barcodes})
    expect(Scan.all).to be_empty
    expect(scan_form.errors.full_messages).to include("Location must have a parent")
  end

  it "existing location which is not a container should not add any type of labware and return an error" do
    location.update(container: false)
    scan_form.submit({"location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes
      })
    expect(Scan.all).to be_empty
    expect(scan_form.errors.full_messages).to include("Location must be a container")
  end

  it "existing location which is not active should not add any type of labware and return an error" do
    location.update(active: false)
    scan_form.submit({"location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes})
    expect(Scan.all).to be_empty
    expect(scan_form.errors.full_messages).to include("Location must be active")
  end

end