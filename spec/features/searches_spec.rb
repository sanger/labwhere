
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
    expect(page).to have_content("New Scan")
  end

  it "with a search term that finds a location should output the results" do
    location = create(:location, name: "A sunny location")
    visit root_path
    fill_in "Term", with: "A sunny location"
    click_button "Search"
    expect(page).to have_content("Your search returned 1 result")
    expect(page).to have_content("#{location.id}. A sunny location - #{location.barcode}")
  end

  it "with a term that finds a location type should output the result" do
    location_type = create(:location_type, name: "A Site")
    visit root_path
    fill_in "Term", with: "Site"
    click_button "Search"
    expect(page).to have_content("Your search returned 1 result")
    expect(page).to have_content("#{location_type.id}. A Site")
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
end
