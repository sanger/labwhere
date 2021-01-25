# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadLabwareForm, type: :model do
  let(:create_upload_labware) { UploadLabwareForm.new }
  let!(:scientist) { create(:scientist) }
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

  it 'will be valid with all its params and a valid user' do
    create_upload_labware.submit(params.merge(upload_labware_form:
      { 'user_code' => scientist.barcode, 'file' => file_param }))
    expect(create_upload_labware.valid?).to eq(true)
  end
end
