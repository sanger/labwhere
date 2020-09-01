# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "MoveLocations", type: :feature do
  let!(:user)             { create(:scientist) }
  let!(:parent_location)  { create(:location_with_parent) }
  let!(:child_locations)  { create_list(:location_with_parent, 5) }

  it "allows a user to move locations" do
    visit new_move_location_path
    expect do
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      fill_in "New location barcode (Parent location)", with: parent_location.barcode
      fill_in "Location barcodes to be moved (Child location)", with: child_locations.join_barcodes
      click_button "Go!"
    end.to change(parent_location.reload.children, :count).by(5)
    expect(page).to have_content("Locations successfully moved")
  end

  it "reports an error if one of the locations is invalid" do
    visit new_move_location_path
    expect do
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      fill_in "New location barcode (Parent location)", with: parent_location.barcode
      fill_in "Location barcodes to be moved (Child location)", with: "#{child_locations.join_barcodes} \nlw-no-location-here"
      click_button "Go!"
    end.to_not change(parent_location.children, :count)
    expect(page).to have_content("error prohibited this record from being saved")
    expect(page).to have_content('Location with barcode lw-no-location-here')
  end
end
