# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UploadFile', type: :feature do
  let!(:user)             { create(:scientist) }

  it 'allows a user to upload a file' do
    visit new_upload_file_path
    fill_in 'User swipe card id/barcode', with: user.swipe_card_id
    attach_file('Upload a file here', Rails.root + 'spec/data/to_upload.csv')
    click_button 'Go!'
    expect(page).to have_content('File successfully uploaded')
  end

  it 'reports an error if the file is the wrong format' do
    visit new_upload_file_path
    fill_in 'User swipe card id/barcode', with: user.swipe_card_id
    attach_file('Upload a file here', Rails.root + 'spec/data/to_upload_wrong_format.txt')
    click_button 'Go!'
    expect(page).to have_content("error prohibited this record from being saved")
    expect(page).to have_content('File must be a csv')
  end
end
