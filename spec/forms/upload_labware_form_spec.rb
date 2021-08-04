# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadLabwareForm, type: :model do
  let(:create_upload_labware) { UploadLabwareForm.new }
  let!(:scientist)            { create(:scientist) }
  let(:params)                { ActionController::Parameters.new(controller: 'upload_labware', action: 'create') }
  let(:file_param)            { ActionDispatch::Http::UploadedFile.new(tempfile: tempfile) }
  let(:tempfile)              { Tempfile.new(['foo', '.csv']) }

  before do
    file_param.content_type = 'text/csv' # doesn't work if set in the initializer
    file_param.original_filename = 'foo.csv'
  end

  it 'will not be valid without the user barcode filled in' do
    create_upload_labware.submit(params.merge(upload_labware_form:
      { 'file' => file_param }))
    expect(create_upload_labware.errors.full_messages).to include('The required fields must be filled in')
  end

  it 'will not be valid without a file selected' do
    create_upload_labware.submit(params.merge(upload_labware_form:
      { 'user_code' => scientist.barcode }))
    expect(create_upload_labware.errors.full_messages).to include('The required fields must be filled in')
  end

  it 'will not be valid without a valid user' do
    create_upload_labware.submit(params.merge(upload_labware_form:
      { 'user_code' => 'dummy_user_code', 'file' => file_param }))
    expect(create_upload_labware.errors.full_messages).to include("User #{I18n.t('errors.messages.existence')}")
  end

  it 'will not be valid with the wrong format of file' do
    create_upload_labware.submit(params.merge(upload_labware_form:
      { 'user_code' => scientist.barcode, 'file' => 'dummy_file' }))
    expect(create_upload_labware.errors.full_messages).to include('File must be a csv.')
  end

  describe '#submit' do
    let(:labware_prefix)  { 'RNA' }
    let!(:locations)      { create_list(:unordered_location_with_parent, 10) }
    let!(:manifest)       { build(:csv_manifest, locations: locations, number_of_labwares: 5, labware_prefix: labware_prefix).generate_csv }

    before do
      tempfile.write(manifest)
      file_param.content_type = 'text/csv' # doesn't work if set in the initializer
      file_param.original_filename = 'foo.csv'
    end

    after do
      tempfile.close
    end

    it 'will be valid with all its params and a valid user' do
      create_upload_labware.submit(params.merge(upload_labware_form:
        { 'user_code' => scientist.barcode, 'file' => file_param }))
      expect(create_upload_labware.valid?).to eq(true)
    end

    it '#format_file_to_json' do
      file = double("file", tempfile: tempfile)
      allow(create_upload_labware).to receive(:file) { file }
      result = create_upload_labware.format_file_to_json
      expect(result[:labwares].length).to eq(50)
      expect(result[:labwares][0]).to have_key(:location_barcode)
      expect(result[:labwares][0]).to have_key(:labware_barcode)
    end
  end
end
