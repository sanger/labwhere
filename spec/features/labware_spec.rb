#As a Sample Management RA I want to scan labware into and out of a location to avoid misplacing biomaterial and delaying pipeline processing
require 'rails_helper'

RSpec.describe "Labware", type: :request do

  it "A user should receive feedback on what Labware is currently in the location" do
    location = create(:location_with_parent, labwares: build_list(:labware, 3))
    visit location_path(location)
    expect(page).to have_content(location.residents)
  end

  describe "Scanning", js: true do

    it "A user should be able to scan 1 or more labware barcodes into a nested location" do
      location = create(:location_with_parent)
      visit edit_location_path(location)
      expect{
        within("#labwares") do
          2.times do |n|
            click_link "Add"
            within all('li').last do
              fill_in "Barcode", with: attributes_for(:labware)[:barcode]
            end
          end
        end
        click_button "Update Location"
      }.to change { location.reload.labwares.count }.by(2)  
    end

    it "A user should be able to remove 1 or more labware barcodes from a nested location" do
      location = create(:location_with_parent, labwares: build_list(:labware, 2))
      visit edit_location_path(location)
      expect{
        within("#labwares") do
          2.times do |n|
            within all('li').last do
              click_link "Remove"
            end
          end
        end
        click_button "Update Location"
      }.to change { location.reload.labwares.count }.by(-2)  
    end
  end
  
end