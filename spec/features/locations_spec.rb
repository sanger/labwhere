#(l1) As a SM manager (Admin) I want to create new locations to enable RAS's track labware whereabouts.

require 'rails_helper'

RSpec.describe "Locations", type: :feature do
  
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

  it "Allows a user to nest locations" do
    location_parent = create(:location)
    location_child = create(:location)
    visit edit_location_path(location_child)
    select location_parent.name, from: "Parent"
    click_button "Update Location"
    expect(location_child.reload.parent).to eq(location_parent)
  end

  it "Does not allow a user to select parent location as itself" do
    location_parent = create(:location)
    location_child = create(:location)
    visit edit_location_path(location_child)
    within("#location_parent_id") do
      expect(page).to_not have_content location_child.name
    end
  end

  it "Does not allow a user to select inactive parent location" do
    location_parent = create(:location, status: Location.statuses[:inactive])
    location_child = create(:location)
    visit edit_location_path(location_child)
    within("#location_parent_id") do
      expect(page).to_not have_content location_parent.name
    end
  end

  it "Allows a user to deactivate a location" do
    location = create(:location)
    visit locations_path
    expect {
      within("#location_#{location.id}") do
        click_link "Edit"
      end
      select "inactive", from: "Status"
      click_button "Update Location"
    }.to change {location.reload.active?}.to(false)
    expect(page).to have_content("Location successfully updated")
  end

end