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

  describe "drilling down", js: true do

    it "with a location type should allow viewing of associated locations" do
      location_type = create(:location_type)
      locations = create_list(:location, 10, location_type: location_type)
      other_locations = create_list(:location, 10, location_type: create(:location_type))
      visit root_path
      fill_in "Term", with: location_type.name
      click_button "Search"
      within("#location_type_#{location_type.id}") do
        click_link "Locations"
      end
      locations.each do |location|
        expect(page).to have_content(location.barcode)
      end
      other_locations.each do |location|
        expect(page).to_not have_content(location.barcode)
      end
    end

    it "with a location should allow viewing of associated labwares" do
      labwares = create_list(:labware, 10)
      location = create(:location_with_parent, labwares: labwares)
      other_labwares = create_list(:labware, 10)
      visit root_path
      fill_in "Term", with: location.barcode
      click_button "Search"
      within("#location_#{location.id}") do
        click_link "Labwares"
      end
      labwares.each do |labware|
        expect(page).to have_content(labware.barcode)
      end
      other_labwares.each do |labware|
        expect(page).to_not have_content(labware.barcode)
      end
    end

    it "with a location type should allow viewing of associated audits" do
      location_type = create(:location_type_with_audits)
      visit root_path
      fill_in "Term", with: location_type.name
      click_button "Search"
      within("#location_type_#{location_type.id}") do
        click_link "Audits"
      end
       location_type.audits.each do |audit|
        expect(page).to have_content(audit.record_data)
      end
    end

    it "with a location should allow viewing of associated audits" do
      location = create(:location_with_audits)
      visit root_path
      fill_in "Term", with: location.barcode
      click_button "Search"
      within("#location_#{location.id}") do
        click_link "Audits"
      end
       location.audits.each do |audit|
        expect(page).to have_content(audit.record_data)
      end
    end

    it "with a location should allow viewing of associated locations and labwares" do
      location = create(:location_with_labwares_and_children)
      visit root_path
      fill_in "Term", with: location.barcode
      click_button "Search"
      within("#location_#{location.id}") do
        click_link "+"
      end
      location.children.each do |child|
        expect(page).to have_content(child.barcode)
      end
      location.labwares.each do |labware|
        expect(page).to have_content(labware.barcode)
      end
    end

    it "with a labware should allow viewing of associated history" do
      labware = create(:labware)
      this_event = create(:history, scan: create(:scan), labware: labware)
      that_event = create(:history, scan: create(:scan), labware: create(:labware))
      visit root_path
      fill_in "Term", with: labware.barcode
      click_button "Search"
      within("#labware_#{labware.id}") do
        click_link "History"
        expect(page).to have_selector("article", count: 1)
        expect(page).to have_content(this_event.scan.user.login)
      end
      
    end

  end

end