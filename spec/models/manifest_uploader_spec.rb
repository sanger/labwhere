
require 'rails_helper'

RSpec.describe ManifestUploader, type: :model do

  let!(:locations)        { create_list(:unordered_location_with_parent, 10) }
  let(:new_location)      { build(:unordered_location) }
  let(:labware_prefix)    { 'RNA' }
  let!(:manifest)         { build(:csv_manifest, locations: locations, number_of_labwares: 5, labware_prefix: labware_prefix )}
  let(:manifest_uploader) { ManifestUploader.new(start_row: 2)}
  let!(:scientist)        { create(:scientist) }

  it 'will have a start row' do
    expect(manifest_uploader.start_row).to eq(2)
  end

  describe 'valid' do

    attr_reader :data

    before(:each) do
      @data = CSV.parse(manifest)
    end

    it 'will create all of the labwares' do
      labwares = Labware.where("barcode LIKE '%#{labware_prefix}%'")
      expect(labwares.count).to eq(50)
    end

    it 'will add all of the labwares to the locations' do
    end

    it 'will create audit records for the labwares' do
    end

  end
end