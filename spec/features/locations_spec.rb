#(l1) As a SM manager (Admin) I want to create new locations to enable RAS's track labware whereabouts.

require 'rails_helper'

RSpec.describe "Locations", type: :feature do

  let!(:user) { create(:administrator)}
  let!(:scientist) { create(:scientist)}

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
      find(:data_id, location_type.id).click_link "Edit"
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
      find(:data_id, location_type.id).click_link "Delete"
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      click_button "Delete"
      expect(page).to have_content("Location type successfully deleted")
      expect(LocationType.find_by(id: location_type.id)).to be_nil
    end

    it "Prevents a user from deleting an existing location type if they are not authorised" do
      location_type = create(:location_type)
      visit location_types_path
      expect {
        find(:data_id, location_type.id).click_link "Delete"
        fill_in "User swipe card id/barcode", with: scientist.swipe_card_id
        click_button "Delete"
      }.to_not change(LocationType, :count)
      expect(page).to have_content("error prohibited this record from being saved")
    end

  end

  it "Should not be able to destroy a location type with an association location" do
    location_type = create(:location_type)
    visit location_types_path
    within("#location_type_#{location_type.id}") do
      expect(page).to_not have_content("Delete")
    end
  end

  let!(:location_types)   { create_list(:location_type, 4)}
  let!(:parent_location)  { create(:unordered_location)}


  it "Allows a user to add a new location" do
    location = build(:location)
    visit locations_path
    click_link "Add new location"
    expect {
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      fill_in "Name", with: location.name
      check "Container"
      click_button "Create Location"
    }.to change(Location, :count).by(1)
    expect(Location.last.reserved?).to eq(false)
    expect(page).to have_content("Location(s) successfully created")
  end

  it "Allows a user to add multiple locations" do
    location = build(:location)
    visit locations_path
    click_link "Add new location"
    expect {
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      fill_in "Name", with: location.name
      fill_in "Start", with: "1"
      fill_in "End", with: "3"
      check "Container"
      click_button "Create Location"
    }.to change(Location, :count).by(3)
    expect(Location.last.reserved?).to eq(false)
    expect(page).to have_content("Location(s) successfully created")
  end

  describe "with coordinates", js: :true do
    it "Allows a user to add a new location with coordinates" do
      location = build(:ordered_location)
      visit locations_path
      click_link "Add new location"
      expect {
        fill_in "User swipe card id/barcode", with: user.swipe_card_id
        fill_in "Name", with: location.name
        select parent_location.id, from: "Parent"
        select location_types.first.name, from: "Location type"
        check "Has Co-ordinates"
        fill_in "Rows", with: location.rows
        fill_in "Columns", with: location.columns
        click_button "Create Location"
      }.to change(Location, :count).by(1)
      expect(OrderedLocation.first.coordinates.count).to eq(create(:ordered_location).coordinates.length)
      expect(page).to have_content("Location(s) successfully created")
    end
  end

  describe "reserved", js: true do
    it "Allows a user to new location that is reserved for their team" do
      location = build(:ordered_location)
      visit locations_path
      click_link "Add new location"

      expect {
        fill_in "User swipe card id/barcode", with: user.swipe_card_id
        fill_in "Name", with: location.name
        select parent_location.id, from: "Parent"
        select location_types.first.name, from: "Location type"
        check "Reserve?"
        click_button "Create Location"
      }.to change(Location, :count).by(1)

      expect(Location.last.team).to eq(user.team)
      expect(page).to have_content("Location(s) successfully created")
    end
  end

  it "Allows a user to add a new location with a parent via a barcode" do
    location = build(:location)
    visit locations_path
    click_link "Add new location"
    expect {
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      fill_in "Name", with: location.name
      select parent_location.id, from: "Parent"
      select location_types.first.name, from: "Location type"
      click_button "Create Location"
    }.to change(Location, :count).by(1)
    expect(Location.last.parent).to eq(parent_location)
    expect(page).to have_content("Location(s) successfully created")
  end

  it "Reports an error if user adds a location with invalid attributes" do
    visit new_location_path
    expect {
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      select location_types.first.name, from: "Location type"
      click_button "Create Location"
    }.to_not change(Location, :count)
    expect(page.text).to match("errors prohibited this record from being saved")
  end

  it "Reports an error if user adds multiple locations and at least one is already present" do
    create(:location, name: "Test Location 2")
    visit new_location_path
    expect {
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      fill_in "Name", with: "Test Location"
      fill_in "Start", with: "1"
      fill_in "End", with: "3"
      check "Container"
      click_button "Create Location"
    }.to_not change(Location, :count)
    expect(page.text).to match("error prohibited this record from being saved")
  end

  it "Allows a user to edit an existing location" do
    location = create(:location)
    visit edit_location_path(location)
    expect {
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      fill_in "Name", with: "An updated location name"
      click_button "Update Location"
    }.to change { location.reload.name }.to("An updated location name")
    expect(page).to have_content("Location successfully updated")
  end

  it "Allows a user to reserve a Location" do
    location = create(:location)

    visit edit_location_path(location)

    expect {
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      check "Reserve?"
      click_button "Update Location"
    }.to change { location.reload.team }.to(user.team)

    expect(page).to have_content("Location successfully updated")
  end

  it "Allows a user to release a Location" do
    location = create(:location, team: user.team)

    visit edit_location_path(location)

    expect {
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      uncheck "Reserve?"
      click_button "Update Location"
    }.to change { location.reload.team }.to(nil)

    expect(page).to have_content("Location successfully updated")
  end

  it "Does not allow a user to release a Location not reserved by their team" do
    reserved_location = create(:location, team: create(:team))

    visit edit_location_path(reserved_location)

    fill_in "User swipe card id/barcode", with: user.swipe_card_id
    uncheck "Reserve?"
    click_button "Update Location"

    expect(page.text).to match("error prohibited this record from being saved")
  end

  it "Allows a user to nest locations" do
    location_parent = create(:unordered_location)
    location_child = create(:location)
    visit edit_location_path(location_child)
    fill_in "User swipe card id/barcode", with: user.swipe_card_id
    select location_parent.barcode, from: "Parent"
    click_button "Update Location"
    expect(location_child.reload.parent).to eq(location_parent)
  end

  it "Does not allow a user to select parent location as itself" do
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
    visit edit_location_path(location)
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
    visit edit_location_path(location)
    expect {
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      check "Active"
      click_button "Update Location"
    }.to change { location.reload.active? }.from(false).to(true)
    expect(page).to have_content("Location successfully updated")
  end

  it "Does not allow an unauthorised user to modify locations" do
    location = build(:location)
    visit locations_path
    click_link "Add new location"
    expect {
      fill_in "User swipe card id/barcode", with: scientist.swipe_card_id
      fill_in "Name", with: location.name
      check "Container"
      click_button "Create Location"
    }.to_not change(Location, :count)
    expect(page).to have_content("error prohibited this record from being saved")
  end

  describe "audits", js: true do

    it "allows a user to view associated audits for a location type" do
      location_type = create(:location_type_with_audits)
      visit location_types_path
      find(:data_id, location_type.id).find(:data_behavior, "audits").click
      expect(find(:data_id, location_type.id)).to have_css("article", count: 5)
    end

    it "allows a user to view associated audits for a location" do
      location = create(:location_with_audits)
      visit location_path(location)
      find(:data_id, location.id).find(:data_behavior, "audits").click
      expect(find(:data_id, location.id)).to have_css("article", count: 5)
    end

    it "allows a user to view further information for each associated audit" do
      location = create(:location_with_audits)
      visit location_path(location)
      find(:data_id, location.id).find(:data_behavior, "audits").click
      within("#audit_#{location.audits.first.id}") do
        find(:data_behavior, "info").click
        expect(page).to have_content("barcode: #{location.barcode}")
      end
    end
  end

  describe "info", js: true do

    it "allows a user to view further information for a location" do
      location = create(:location)
      visit location_path(location)
      find(:data_id, location.id).click_link "Further information"
      expect(find(:data_id, location.id).find(:data_output, "info-text")).to have_content(location.location_type.name)
    end

  end

  describe "destroying location", js: true do
    it "will destroy" do
      location = create(:unordered_location)
      visit locations_path
      find(:data_id, location.id).click_link "Delete"
      fill_in "User swipe card id/barcode", with: user.swipe_card_id
      click_button "Delete"
      expect(page).to have_content("Location successfully deleted")
      expect(Location.find_by(id: location.id)).to be_nil
    end
    it "wont have the link" do
      location = create(:unordered_location_with_children)
      visit locations_path
      expect(find(:data_id, location.id)).to_not have_link("Delete")

    end
  end
end
