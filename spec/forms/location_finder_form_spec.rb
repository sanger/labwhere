# frozen_string_literal: true

require 'rails_helper'

# We just need to create a mock temp file so the location finder is valid
# We could mock the location finder but better to mock the temp file so we
# know that the interaction between the form and the model is working
# create a tempfile, add some data and set the content type.
# TODO: might be an idea to move this into a rspec helper
def create_file(name, type, content_type)
  temp_file = Tempfile.new([name, type])
  temp_file.write("DN123\nDN456\n")
  temp_file.rewind # rewind writes the data otherwise the file is still empty
  file = ActionDispatch::Http::UploadedFile.new(tempfile: temp_file)

  # doesn't work if set in the initializer
  file.content_type = content_type
  file.original_filename = "#{name}#{type}"
  file
end

RSpec.describe LocationFinderForm, type: :model do
  let(:location_finder_form)  { LocationFinderForm.new }
  let!(:user)                 { create(:scientist) }
  let(:params)                { ActionController::Parameters.new }
  let(:csv_file)              { create_file('foo', '.csv', 'text/csv') }
  let(:txt_file)              { create_file('foo', '.txt', 'text/plain') }

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

  it 'will be valid with all its params' do
    csv_file.open
    location_finder_form.submit(params.merge(location_finder_form:
      { 'file' => csv_file }))
    expect(location_finder_form.valid?).to eq(true)
  end
end
