#(l1) As a SM manager (Admin) I want to create new locations to enable RAS's track labware whereabouts.

require 'rails_helper'

RSpec.describe "Locations", type: :feature do

  let!(:user) { create(:admin)}

  it "Allows a user to add a new location type" do
    location_type = build(:location_type)
    visit location_types_path
    click_link "Add new location type"
    expect {
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      fill_in "Name", with: location_type.name
      click_button "Create Location type"
    }.to change(LocationType, :count).by(1)
    expect(page).to have_content("Location type successfully created")
  end

  it "Reports an error if user adds a location type with invalid attributes" do
    visit new_location_type_path
    expect {
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
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
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      fill_in "Name", with: "Updated location type"
      click_button "Update Location type"
    }.to change { location_type.reload.name }.to("Updated location type")
    expect(page).to have_content("Location type successfully updated")
  end

  describe "deleting", js: true do

    it "Allows a user to delete an existing location type" do
      location_type = create(:location_type)
      visit location_types_path
      within("#location_type_#{location_type.id}") do
        click_link "Delete"
      end
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      click_button "Delete"
      expect(page).to have_content("Location type successfully deleted")
      expect(LocationType.find_by(id: location_type.id)).to be_nil
    end

    it "Prevents a user from deleting an existing location type if they are not authorised" do
      location_type = create(:location_type)
      standard_user = create(:standard)
      visit location_types_path
      expect {
        within("#location_type_#{location_type.id}") do
          click_link "Delete"
        end
        fill_in "User swipe card id/barcode", with: standard_user.swipe_card_id
        click_button "Delete"
      }.to_not change(LocationType, :count)
      expect(page).to have_content("error prohibited this record from being saved")
    end

  end

  it "Should not be able to destroy a location type with an association location" do
    location_type = create(:location_type)
    location = create(:location, location_type: location_type)
    visit location_types_path
    within("#location_type_#{location_type.id}") do
      expect(page).to_not have_content("Delete")
    end
  end

  let!(:location_types)   { create_list(:location_type, 4)}
  let!(:parent_location)  { create(:location)}

  
  it "Allows a user to add a new location" do
    location = build(:location)
    visit locations_path
    click_link "Add new location"
    expect {
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      fill_in "Name", with: location.name
      select location_types.first.name, from: "Location type"
      check "Container"
      click_button "Create Location"
    }.to change(Location, :count).by(1)
    expect(page).to have_content("Location successfully created")
  end

  it "Allows a user to add a new location with a parent via a barcode" do
    location = build(:location)
    visit locations_path
    click_link "Add new location"
    expect {
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      fill_in "Name", with: location.name
      fill_in "Parent barcode", with: parent_location.barcode
      select location_types.first.name, from: "Location type"
      check "Container"
      click_button "Create Location"
    }.to change(Location, :count).by(1)
    expect(Location.last.parent).to eq(parent_location)
    expect(page).to have_content("Location successfully created")
  end

  it "Reports an error if user adds a location with invalid attributes" do
    location = build(:location)
    visit new_location_path
    expect {
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
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
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      fill_in "Name", with: "An updated location name"
      click_button "Update Location"
    }.to change { location.reload.name }.to("An updated location name")
    expect(page).to have_content("Location successfully updated")
  end



  it "Allows a user to nest locations" do
    location_parent = create(:location)
    location_child = create(:location)
    visit edit_location_path(location_child)
    fill_in "User swipe card id/barcode", with: user.swipe_card_id
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
    within("#location_#{location.id}") do
        click_link "Edit"
      end
    expect {
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      uncheck "Active"
      click_button "Update Location"
    }.to change { location.reload.active? }.from(true).to(false)
    expect(page).to have_content("Location successfully updated")
  end

  it "Allows a user to activate a location" do
    location = create(:location)
    location.deactivate
    visit locations_path
    within("#location_#{location.id}") do
        click_link "Edit"
      end
    expect {
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      check "Active"
      click_button "Update Location"
    }.to change { location.reload.active? }.from(false).to(true)
    expect(page).to have_content("Location successfully updated")
  end

  it "Does not allow an unauthorised user to modify locations" do
    location = build(:location)
    standard_user = create(:standard)
    visit locations_path
    click_link "Add new location"
    expect {
      fill_in "User swipe card id/barcode", with: standard_user.swipe_card_id
      fill_in "Name", with: location.name
      select location_types.first.name, from: "Location type"
      check "Container"
      click_button "Create Location"
    }.to_not change(Location, :count)
    expect(page).to have_content("error prohibited this record from being saved")
  end

end