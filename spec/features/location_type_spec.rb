require 'rails_helper'

RSpec.describe "Location Type", :type => :request do
  it "Allows a user to add a new location type" do
    location_type = build(:location_type)
    visit location_types_path
    click_link "Add new location type"
    expect {
      fill_in "Name", with: location_type.name
      click_button "Create Location type"
    }.to change(LocationType, :count).by(1)
    expect(page).to have_content("Location type successfully created")
  end

  it "Reports an error if user adds a location type with invalid attributes" do
    visit new_location_type_path
    expect {
      click_button "Create Location type"
    }.to_not change(LocationType, :count)
    expect(page.text).to match("error prohibited this record from being saved")
  end

  it "Allows a user to edit an existing location type" do
    location_type = create(:location_type)
    visit location_types_path
    expect {
      within("#location_type_#{location_type.id}") do
        click_link "Edit"
      end
      fill_in "Name", with: "Updated location type"
      click_button "Update Location type"
    }.to change { location_type.reload.name }.to("Updated location type")
    expect(page).to have_content("Location type successfully updated")
  end

  it "Allows a user to delete an existing location type" do
    location_type = create(:location_type)
    visit location_types_path
    expect {
      within("#location_type_#{location_type.id}") do
        click_link "Delete"
      end
    }.to change(LocationType, :count).by(-1)
    expect(page).to have_content("Location type successfully deleted")
  end
end