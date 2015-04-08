require 'rails_helper'

RSpec.describe "Location", :type => :request do

  let!(:location_types) { create_list(:location_type, 4)}
  
  it "Allows a user to add a new location" do
    location = build(:location)
    visit locations_path
    click_link "Add new location"
    expect {
      fill_in "Name", with: location.name
      select location_types.first.name, from: "Location type"
      check "Container"
      click_button "Create Location"
    }.to change(Location, :count).by(1)
    expect(page).to have_content("Location successfully created")
  end

  it "Reports an error if user adds a location with invalid attributes" do
    location = build(:location)
    visit new_location_path
    expect {
      select location_types.first.name, from: "Location type"
      check "Container"
      click_button "Create Location"
    }.to_not change(Location, :count)
    expect(page.text).to match("error prohibited this record from being saved")
  end

  it "Allows a user to edit an existing location" do
    location = create(:location)
    visit locations_path
    expect {
      within("#location_#{location.id}") do
        click_link "Edit"
      end
      fill_in "Name", with: "An updated location name"
      click_button "Update Location"
    }.to change { location.reload.name }.to("An updated location name")
    expect(page).to have_content("Location successfully updated")
  end
end