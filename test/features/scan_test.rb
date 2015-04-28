require "test_helper"

class ScanTest < Capybara::Rails::TestCase

  test "allows a user to scan in some labware with a location" do
    location = create(:location_with_parent)
    labwares = build_list(:labware, 10)
    visit new_scan_path
    fill_in "Location barcode", with: location.barcode
    fill_in "Labware barcodes", with: labwares.join_barcodes
    click_button "Go!"
    assert_equal 1, Scan.count
    assert_content page, "Scan done!"
  end

  test "allows a user to scan out some labware with no location" do
    labwares = create_list(:labware, 10, location: create(:location_with_parent))
    visit new_scan_path
    fill_in "Labware barcodes", with: labwares.join_barcodes
    click_button "Go!"
    assert_equal 1, Scan.count
    assert_content page, "Scan done!"
  end

  test "shows an error if the location is invalid" do
    location = create(:location)
    labwares = build_list(:labware, 10)
    visit new_scan_path
    fill_in "Location barcode", with: location.barcode
    fill_in "Labware barcodes", with: labwares.join_barcodes
    click_button "Go!"
    assert Scan.all.empty?
    assert page.has_field?("Location barcode", with: location.barcode)
    assert_content page, "error prohibited this record from being saved"
    assert_content page, labwares.join_barcodes(" ")
  end
end
