# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ManifestUploader, type: :model do
  let!(:locations)         { create_list(:unordered_location_with_parent, 10) }
  let!(:ordered_locations) { create_list(:ordered_location_with_parent, 10) }
  let(:new_location)       { build(:unordered_location, barcode: 'unknown') }
  let(:ordered_location)   { create(:ordered_location_with_parent) }
  let(:unordered_location) { create(:unordered_location_with_parent) }
  let!(:equal_positions)   { generate_positions(50) }
  let(:labware_prefix)     { 'RNA' }
  let!(:scientist)         { create(:scientist) }
  let(:manifest_uploader)  { ManifestUploader.new(user: scientist) }
  let(:invalid_position)   { 20 }

  context 'with unordered locations that all exist' do
    let!(:manifest) { build(:csv_manifest, locations: locations, number_of_labwares: 5, labware_prefix: labware_prefix).generate_csv }

    attr_reader :data

    before(:each) do
      manifest_uploader.file = manifest
      manifest_uploader.run
    end

    it 'will create all of the labwares' do
      labwares = Labware.where("barcode LIKE '%#{labware_prefix}%'")
      expect(labwares.count).to eq(50)
    end

    it 'will add all of the labwares to the locations' do
      locations.each do |location|
        expect(location.labwares.count).to eq(5)
      end
    end

    it 'will create audit records for the labwares' do
      labwares = Labware.where("barcode LIKE '%#{labware_prefix}%'")
      expect(labwares.first.audits.last.action).to eq("Uploaded from manifest")
      expect(labwares.last.audits.last.action).to eq("Uploaded from manifest")
    end
  end

  context 'when there is a location that is not valid' do
    let!(:manifest) { build(:csv_manifest, locations: locations + [new_location], number_of_labwares: 5, labware_prefix: labware_prefix).generate_csv }

    attr_reader :data

    before(:each) do
      manifest_uploader.file = manifest
    end

    it 'will not be valid' do
      expect(manifest_uploader).to_not be_valid
    end

    it 'will show an error' do
      manifest_uploader.run
      expect(manifest_uploader.errors.full_messages).to include("location(s) with barcode #{new_location.barcode} do not exist")
    end

    it 'will not create any labwares' do
      manifest_uploader.run
      labwares = Labware.where("barcode LIKE '%#{labware_prefix}%'")
      expect(labwares).to be_empty
    end
  end

  context 'with ordered locations which all exist' do
    let!(:manifest) { build(:csv_manifest, locations: ordered_locations, number_of_labwares: 5, labware_prefix: labware_prefix, positions: equal_positions).generate_csv }

    attr_reader :data

    before(:each) do
      manifest_uploader.file = manifest
      manifest_uploader.run
    end

    it 'will add the labwares to the defined positions' do
      labwares = Labware.where.not(coordinate_id: nil)
      expect(labwares.count).to eq(50)
    end
  end

  context 'when there are invalid positions defined for ordered locations' do
    let!(:manifest) { build(:csv_manifest, locations: [ordered_location], number_of_labwares: 3, labware_prefix: labware_prefix, positions: ["", 1.5, "string"]).generate_csv }

    attr_reader :data

    before(:each) do
      manifest_uploader.file = manifest
    end

    it 'will not be valid' do
      expect(manifest_uploader).to_not be_valid
    end

    it 'will show an error' do
      manifest_uploader.run
      expect(manifest_uploader.errors.full_messages).to contain_exactly("Line 2: invalid entry for position. Please specify a positive integer.",
                                                                        "Line 3: invalid entry for position. Please specify a positive integer.",
                                                                        "Line 4: invalid entry for position. Please specify a positive integer.")
    end
  end

  context 'when a position does not exist' do
    let!(:manifest) { build(:csv_manifest, locations: [ordered_location], number_of_labwares: 1, labware_prefix: labware_prefix, positions: [invalid_position]).generate_csv }

    attr_reader :data

    before(:each) do
      manifest_uploader.file = manifest
    end

    it 'will not be valid' do
      expect(manifest_uploader).to_not be_valid
    end

    it 'will show an error' do
      manifest_uploader.run
      expect(manifest_uploader.errors.full_messages).to include("Line 2: target position #{invalid_position} for location with barcode #{ordered_location.barcode} does not exist")
    end
  end

  context 'when there are duplicate positions entered' do
    let!(:manifest) { build(:csv_manifest, locations: [ordered_location], number_of_labwares: 2, labware_prefix: labware_prefix, positions: [1, 1]).generate_csv }

    attr_reader :data

    before(:each) do
      manifest_uploader.file = manifest
    end

    it 'will not be valid' do
      expect(manifest_uploader).to_not be_valid
    end

    it 'will show an error' do
      manifest_uploader.run
      expect(manifest_uploader.errors.full_messages).to include("Lines 2,3: duplicate target positions")
    end
  end

  context 'when there is a position which is already occupied' do
    let!(:existing_labware) { create(:labware, location_id: ordered_location.id, coordinate_id: Coordinate.find_by(location_id: ordered_location.id, position: 1).id) }
    let!(:manifest) { build(:csv_manifest, locations: [ordered_location], number_of_labwares: 1, labware_prefix: labware_prefix, positions: [1]).generate_csv }

    attr_reader :data

    before(:each) do
      manifest_uploader.file = manifest
    end

    it 'will not be valid' do
      expect(manifest_uploader).to_not be_valid
    end

    it 'will show an error' do
      manifest_uploader.run
      expect(manifest_uploader.errors.full_messages).to include("Line 2: target position 1 for labware with barcode RNA000001 is already occupied")
    end
  end

  context 'with both ordered and unordered locations which exist' do
    let!(:manifest) { build(:csv_manifest, locations: [unordered_location, ordered_location], number_of_labwares: 1, labware_prefix: labware_prefix, positions: ["", 1]).generate_csv }

    attr_reader :data

    before(:each) do
      manifest_uploader.file = manifest
      manifest_uploader.run
    end

    it 'will add the labware to the defined ordered location' do
      labwares = Labware.where.not(coordinate_id: nil)
      expect(labwares.count).to eq(1)
    end

    it 'will add the labware to the defined unordered location' do
      labwares = Labware.where(coordinate_id: nil)
      expect(labwares.count).to eq(1)
    end
  end

  def generate_positions(num)
    n = 1
    positions = []
    1.upto(num).each do
      positions.push(n)
      n += 1
      n = 1 if n == 6
    end
    positions
  end
end
