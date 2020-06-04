# frozen_string_literal: true

# (l2) As a Sample Management RA I want to scan labware into and out of a location to avoid misplacing biomaterial and delaying pipeline processing

require 'rails_helper'

RSpec.describe "MoveLocations", type: :feature do
  let!(:user)             { create(:scientist) }
  let!(:parent_location)  { create(:location_with_parent)}
  let!(:child_locations)  { create_list(:location_with_parent, 5)}

  it "allows a user to move locations" do
    visit new_move_location_path
    expect {
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      fill_in "Parent location barcode", with: parent_location.barcode
      fill_in "Child location barcodes", with: child_locations.join_barcodes
      click_button "Go!"
    }.to change(parent_location.reload.children, :count).by(5)
    expect(page).to have_content("Locations successfully moved")
  end

  it "reports an error if one of the locations is invalid" do
    visit new_move_location_path
    expect {
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      fill_in "Parent location barcode", with: parent_location.barcode
      fill_in "Child location barcodes", with: child_locations.join_barcodes + "\nlw-no-location-here"
      click_button "Go!"
    }.to_not change(parent_location.children, :count)
    expect(page).to have_content("error prohibited this record from being saved")
    expect(page).to have_content('Location with barcode lw-no-location-here')
  end

end
