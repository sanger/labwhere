# frozen_string_literal: true

# GPL-479 empty a container in LabWhere presto-hay

require 'rails_helper'

RSpec.describe "EmptyLocations", type: :feature do
  let!(:tech_swipe_card_id) { generate(:swipe_card_id) }
  let!(:technician) { create(:technician, swipe_card_id: tech_swipe_card_id) }
  let!(:location) { create(:unordered_location_with_labwares) }

  it "allows a user to empty locations" do
    visit new_empty_location_path
    fill_in "User swipe card id/barcode", with: tech_swipe_card_id
    fill_in "Barcode of location to be emptied", with: "#{location.barcode}\n"
    click_button "Go!"
    expect(location.reload.labwares).to be_empty
    expect(page).to have_content("Location successfully emptied")
  end

  it "reports an error if the location is invalid" do
    visit new_empty_location_path
    fill_in "User swipe card id/barcode", with: tech_swipe_card_id
    fill_in "Barcode of location to be emptied", with: "lw-no-location-here"
    click_button "Go!"
    expect(page).to have_content("error prohibited this record from being saved")
    expect(page).to have_content('Location with barcode lw-no-location-here')
  end
end
