#(l4) As a Sample management RA I want to search for labware or location via barcode to find biomaterial I need for processing 
require 'rails_helper'

RSpec.describe "Searches", type: :feature do

  it "should be successful with a search term" do
    visit root_path
    fill_in "Term", with: "A search term"
    click_button "Search"
    expect(page).to have_content("Your search returned 0 results")
  end

  it "should fail silently if somebody clicks the search button for no reason" do
    visit root_path
    click_button "Search"
    expect(page).to have_content("Scan In/Out")
  end

  it "with a search term that finds a location should output the results" do
    location = create(:location, name: "A sunny location")
    visit root_path
    fill_in "Term", with: "A sunny location"
    click_button "Search"
    expect(page).to have_content("Your search returned 1 result")
    expect(page).to have_content(location.barcode)
  end

  it "with a term that finds a location type should output the result" do
    location_type = create(:location_type, name: "A Site")
    visit root_path
    fill_in "Term", with: "Site"
    click_button "Search"
    expect(page).to have_content("Your search returned 1 result")
    expect(page).to have_content("A Site")
  end

  it "with a term that finds labware should output the result" do
    labwares = create_list(:labware, 2)
    visit root_path
    fill_in "Term", with: labwares.first.barcode
    click_button "Search"
    expect(page).to have_content("Your search returned 1 result")
    expect(page).to have_content(labwares.first.barcode)
  end

  it "with a term that spans more than one resource should output all of the results" do
    location = create(:location, name: "A stupid name")
    labware = create(:labware, barcode: "A stupid barcode", location: create(:location_with_parent))
    visit root_path
    fill_in "Term", with: "A stupid"
    click_button "Search"
    expect(page).to have_content("Your search returned 2 results")
    expect(page).to have_content(location.name)
    expect(page).to have_content(labware.barcode)
  end

  describe "drilling down", js: true do

    it "with a location type should allow viewing of associated locations" do
      location_type = create(:location_type_with_locations)
      other_locations = create_list(:location, 10, location_type: create(:location_type))
      visit root_path
      fill_in "Term", with: location_type.name
      click_button "Search"
      find(:data_id,location_type.id).find(:data_behavior, "drilldown").click
      location_type.locations.each do |location|
        expect(page).to have_content(location.barcode)
      end
      other_locations.each do |location|
        expect(page).to_not have_content(location.barcode)
      end
    end

    it "with a location should allow viewing of associated locations and labwares" do
      location = create(:location_with_labwares_and_children)
      visit root_path
      fill_in "Term", with: location.barcode
      click_button "Search"
      find(:data_id, location.id).find(:data_behavior, "drilldown").click
      location.children.each do |child|
        expect(page).to have_content(child.barcode)
      end
      location.labwares.each do |labware|
        expect(page).to have_content(labware.barcode)
        within("#labware_#{labware.id}") do
          click_link("Further information")
          expect(page).to have_content(labware.location.barcode)
        end
      end
    end

     it "with a location should allow viewing of associated location further information" do
      location = create(:location_with_labwares_and_children)
      visit root_path
      fill_in "Term", with: location.barcode
      click_button "Search"
      within("#location_#{location.id}") do
        find(:data_behavior, "drilldown").click
        within("#location_#{location.children.first.id}") do
          click_link("Further information")
          expect(page).to have_content(location.children.first.location_type.name)
        end
      end
    end

    it "with a labware should allow viewing of associated history" do
      labware = create(:labware_with_histories)
      visit root_path
      fill_in "Term", with: labware.barcode
      click_button "Search"
      find(:data_id, labware.id).find(:data_behavior, "drilldown").click
      labware.histories.each do |history|
        expect(page).to have_content(history.summary)
      end
    end

  end

end