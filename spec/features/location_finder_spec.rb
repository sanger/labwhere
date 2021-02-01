# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'LocationFinder', type: :feature do
  let!(:labwares)     { create_list(:labware_with_location, 3) }
  let(:file_data)     { labwares.collect(&:barcode).join('\n') }
  let(:csv_file)      { create_temp_file('labwares', '.csv', 'text/csv', file_data) }
  let(:text_file)     { create_temp_file('labwares', '.txt', 'text/plain', file_data) }

  it 'allows a user to find some locations' do
    visit new_location_finder_path
    attach_file('Upload a file here', csv_file.path)
    click_button 'Go!'
    expect(page.response_headers['Content-Type']).to include("text/csv")
    header = page.response_headers['Content-Disposition']
    expect(header).to match(/^attachment/)
    expect(header).to match(/filename=locations.csv$/)
  end

  it 'reports an error if there is something wrong' do
    visit new_location_finder_path
    attach_file('Upload a file here', text_file.path)
    click_button 'Go!'
    expect(page).to have_content("error prohibited this record from being saved")
  end
end
