# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationFinderForm, type: :model do
  let(:location_finder_form)  { LocationFinderForm.new }
  let!(:user)                 { create(:scientist) }
  let(:params)                { ActionController::Parameters.new }
  let(:file_data)             { "DN123\nDN456\n" }

  # We just need to create a mock temp file so the location finder is valid
  # We could mock the location finder but better to mock the temp file so we
  # know that the interaction between the form and the model is working
  let(:csv_file)              { create_temp_file('foo', '.csv', 'text/csv', file_data) }
  let(:csv_file_bad_data)     { create_temp_file('foo_2', '.csv', 'text/csv', 'DN1234,DN456') }
  let(:txt_file)              { create_temp_file('foo', '.txt', 'text/plain', file_data) }

  it 'will not be valid when no params are provided' do
    location_finder_form.submit(params)
    expect(location_finder_form.errors.full_messages).to eq(
      [
        'The required fields must be filled in',
        'File is empty',
        'There is something wrong with the file. There should only be 1 column with barcodes.'
      ]
    )
  end

  it 'will not be valid without a file selected' do
    location_finder_form.submit(params.merge(location_finder_form:
      {}))
    expect(location_finder_form.errors.full_messages).to include('The required fields must be filled in')
  end

  it 'will not be valid with the wrong format of file' do
    # you need to open the file as the stream is closed.
    txt_file.open
    location_finder_form.submit(params.merge(location_finder_form:
      { 'file' => txt_file }))
    expect(location_finder_form.errors.full_messages).to include('File must be a csv. Provided: .txt')
  end

  it 'will not be valid with the wrong file contents' do
    csv_file_bad_data.open
    location_finder_form.submit(params.merge(location_finder_form:
      { 'file' => csv_file_bad_data }))
    expect(location_finder_form.errors.full_messages).to include(
      'There is something wrong with the file. There should only be 1 column with barcodes.'
    )
  end

  it 'will be valid with all its params' do
    csv_file.open
    location_finder_form.submit(params.merge(location_finder_form:
      { 'file' => csv_file }))
    expect(location_finder_form.valid?).to eq(true)
  end
end
