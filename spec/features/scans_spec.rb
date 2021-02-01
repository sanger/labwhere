# frozen_string_literal: true

# (l2) As a Sample Management RA I want to scan labware into and out of a location to avoid misplacing biomaterial and delaying pipeline processing

require 'rails_helper'

RSpec.describe "Scans", type: :feature do
  include_context "shared helpers"

  let!(:sci_swipe_card_id) { generate(:swipe_card_id) }
  let!(:scientist) { create(:scientist, swipe_card_id: sci_swipe_card_id) }

  it "allows a user to scan in some labware with a location" do
    location = create(:location_with_parent)
    labwares = build_list(:labware, 10)
    visit new_scan_path
    expect {
      fill_in "User swipe card id/barcode", with: sci_swipe_card_id
      fill_in "Location barcode", with: location.barcode
      fill_in "Labware barcodes", with: labwares.join_barcodes
      click_button "Go!"
    }.to change(Scan, :count).by(1)
    expect(page).to have_content(Scan.first.message)
  end

  it 'displays the line number for scanned labware', js: true do
    location = create(:location_with_parent)
    labwares = build_list(:labware, 34)
    visit new_scan_path
    fill_in "User swipe card id/barcode", with: sci_swipe_card_id
    fill_in "Location barcode", with: location.barcode
    expect(page.all('.CodeMirror-linenumber').count).to eq(1)
    fill_in_labware_barcodes(labwares.join_barcodes)
    expect(page.all('.CodeMirror-linenumber').count).to eq(34)
  end

  it 'displays duplicate barcodes in an error color', js: true do
    location = create(:location_with_parent)
    visit new_scan_path
    fill_in "User swipe card id/barcode", with: sci_swipe_card_id
    fill_in "Location barcode", with: location.barcode
    expect(page.all('.cm-error').count).to eq(0)
    fill_in_labware_barcodes("1234\n")
    expect(page.all('.cm-error').count).to eq(0)
    fill_in_labware_barcodes("4567\n")
    expect(page.all('.cm-error').count).to eq(0)
    fill_in_labware_barcodes("1234\n")
    expect(page.all('.cm-error').count).to eq(1)
    fill_in_labware_barcodes("4567\n")
    expect(page.all('.cm-error').count).to eq(2)
  end

  it "allows a user to scan is some labware to a location with coordinates" do
    location = create(:ordered_location_with_parent, rows: 5, columns: 5)
    labwares = build_list(:labware, 10)
    visit new_scan_path
    expect {
      fill_in "User swipe card id/barcode", with: sci_swipe_card_id
      fill_in "Location barcode", with: location.barcode
      fill_in "Labware barcodes", with: labwares.join_barcodes
      fill_in "Start position", with: 5
      click_button "Go!"
    }.to change(Scan, :count).by(1)
    expect(page).to have_content(Scan.first.message)
  end

  it "allows a user to scan out some labware with no location" do
    labwares = create_list(:labware, 10, location: create(:location_with_parent))
    visit new_scan_path
    expect {
      fill_in "User swipe card id/barcode", with: sci_swipe_card_id
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
      fill_in "User swipe card id/barcode", with: sci_swipe_card_id
      fill_in "Location barcode", with: location.barcode
      fill_in "Labware barcodes", with: labwares.join_barcodes
      click_button "Go!"
    }.to_not change(Scan, :count)
    expect(page).to have_content("error prohibited this record from being saved")
    expect(page).to have_field("Location barcode", with: location.barcode)
    expect(page).to have_content(labwares.join_barcodes("\r "))
  end

  it "Does not allow an unauthorised user to modify locations" do
    location = create(:location_with_parent)
    labwares = build_list(:labware, 10)
    visit new_scan_path
    expect {
      fill_in "Location barcode", with: location.barcode
      fill_in "Labware barcodes", with: labwares.join_barcodes
      click_button "Go!"
    }.to_not change(Scan, :count)
    expect(page).to have_content("errors prohibited this record from being saved")
  end

  describe "Reservations" do
    it "does not allow a user to scan labware into a location reserved by another team" do
      location = create(:location_with_parent, team: create(:team))
      labwares = build_list(:labware, 10)
      visit new_scan_path

      expect {
        fill_in "User swipe card id/barcode", with: sci_swipe_card_id
        fill_in "Location barcode", with: location.barcode
        fill_in "Labware barcodes", with: labwares.join_barcodes
        click_button "Go!"
      }.to_not change(Scan, :count)

      expect(page).to have_content("error prohibited this record from being saved")
    end

    it "does not allow a user to scan labware out of a location reserved by another team" do
      labwares = create_list(:labware, 10, location: create(:location_with_parent, team: create(:team)))
      visit new_scan_path

      expect {
        fill_in "User swipe card id/barcode", with: sci_swipe_card_id
        fill_in "Labware barcodes", with: labwares.join_barcodes
        click_button "Go!"
      }.to change(Scan, :count).by(0)

      expect(page).to have_content("errors prohibited this record from being saved")
    end

    it "does not allow a user to scan labware out of a location with a parent reserved by another team" do
      parent_location = create(:location, team: create(:team))
      labwares = create_list(:labware, 10, location: create(:location_with_parent, parent: parent_location))

      visit new_scan_path

      expect {
        fill_in "User swipe card id/barcode", with: sci_swipe_card_id
        fill_in "Labware barcodes", with: labwares.join_barcodes
        click_button "Go!"
      }.to change(Scan, :count).by(0)

      expect(page).to have_content("errors prohibited this record from being saved")
    end
  end
end
