# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UploadLabware', type: :feature do
  let!(:sci_swipe_card_id) { generate(:swipe_card_id) }
  let!(:scientist) { create(:scientist, swipe_card_id: sci_swipe_card_id) }

  before do
    # TODO: should be using factories and before each
    location_type = LocationType.create!(name: 'test_location_type')
    parent_location = UnorderedLocation.create!(name: 'parent location', location_type: location_type)
    box1 = UnorderedLocation.create!(name: 'box 1', location_type: location_type, parent: parent_location)
    box2 = UnorderedLocation.create!(name: 'box 2', location_type: location_type, parent: parent_location)
    box1.update!(barcode: 'BX1234')
    box2.update!(barcode: 'BX5678')
  end

  it 'allows a user to upload a file' do
    visit new_upload_labware_path
    fill_in 'User swipe card id/barcode', with: sci_swipe_card_id
    attach_file('Upload a file here', Rails.root.join('spec/data/to_upload.csv'))
    click_button 'Go!'
    expect(page).to have_content('Labware successfully uploaded')
  end

  it 'reports an error if the file is the wrong format' do
    visit new_upload_labware_path
    fill_in 'User swipe card id/barcode', with: sci_swipe_card_id
    attach_file('Upload a file here', Rails.root.join('spec/data/to_upload_wrong_format.txt'))
    click_button 'Go!'
    expect(page).to have_content("error prohibited this record from being saved")
    expect(page).to have_content('File must be a csv.')
  end
end
