
require 'rails_helper'

RSpec.describe ManifestUploader, type: :model do

  let!(:locations)        { create_list(:location, 10) }
  let(:new_location)      { build(:location) }
  let!(:manifest)         { build(:csv_manifest, locations: locations)}
  let(:manifest_uploader) { ManifestUploader.new(start_row: 2)}
  let!(:scientist)        { create(:scientist) }

  it 'will have a start row' do
    expect(manifest_uploader.start_row).to eq(2)
  end

  describe 'valid' do

    it 'will create all of the labwares' do
    end

    it 'will add the labwares to the locations'

    it 'will create audit records for the labwares'

  end
end