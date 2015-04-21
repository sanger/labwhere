require 'rails_helper'

describe ScanForm do

  let!(:location)         { create(:location_with_parent)}
  let(:scan_form)         { ScanForm.new}
  let(:new_labware)       { build_list(:labware, 4)}
  let!(:existing_labware) { create_list(:labware, 4, location: create(:location_with_parent))}

  it "should have a location barcode" do
    scan_form.location_barcode = "A barcode"
    expect(scan_form.location_barcode).to eq("A barcode")
  end

  it "should have labware barcodes" do
    scan_form.labware_barcodes = "Some barcodes"
    expect(scan_form.labware_barcodes).to eq("Some barcodes")
  end

  it "should be able to scan stuff in" do
    scan_form.submit({"location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes})
    expect(Scan.all).to_not be_empty
  end

  it "should be able to scan stuff out" do
    scan_form.submit({"location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes})
    expect(Scan.all).to_not be_empty
  end

  it "should produce an error if something goes wrong" do
    location.update(container: false)
    scan_form.submit({"location_barcode" => location.barcode, "labware_barcodes" => new_labware.join_barcodes
      })
    expect(Scan.all).to be_empty
    expect(scan_form.errors).to_not be_empty
  end

end