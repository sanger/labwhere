#(l2) As a Sample Management RA I want to scan labware into and out of a location to avoid misplacing biomaterial and delaying pipeline processing

require 'rails_helper'

RSpec.describe "Scans", type: :feature do

  it "allows a user to scan in some labware with a location" do
    location = create(:location_with_parent)
    labwares = build_list(:labware, 10)
    visit new_scan_path
    expect {
      fill_in "Location barcode", with: location.barcode
      fill_in "Labware barcodes", with: labwares.join_barcodes
      click_button "Go!"
    }.to change(Scan, :count).by(1)
    expect(page).to have_content(Scan.first.message)
  end

  it "allows a user to scan out some labware with no location" do
    labwares = create_list(:labware, 10, location: create(:location_with_parent))
    visit new_scan_path
    expect {
      fill_in "Labware barcodes", with: labwares.join_barcodes
      click_button "Go!"
    }.to change(Scan, :count).by(1)
    expect(page).to have_content(Scan.first.message)
  end

  it "reports an error if the user adds a scan with invalid attributes" do
    location = create(:location)
    labwares = build_list(:labware, 10)
    visit new_scan_path
    expect {
      fill_in "Location barcode", with: location.barcode
      fill_in "Labware barcodes", with: labwares.join_barcodes
      click_button "Go!"
    }.to_not change(Scan, :count)
    expect(page.text).to match("error prohibited this record from being saved")
    expect(page).to have_field("Location barcode", with: location.barcode)
    expect(page).to have_content(labwares.join_barcodes)
  end

end