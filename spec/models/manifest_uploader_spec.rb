# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ManifestUploader, type: :model do
  let!(:locations)         { create_list(:unordered_location_with_parent, 10) }
  let!(:ordered_locations) { create_list(:ordered_location_with_parent, 10) }
  let(:new_location)       { build(:unordered_location, barcode: 'unknown') }
  let(:ordered_location)   { create(:ordered_location_with_parent) }
  let(:unordered_location) { create(:unordered_location_with_parent) }
  let(:labware_prefix)     { 'RNA' }
  let!(:scientist)         { create(:scientist) }
  let(:manifest_uploader)  { ManifestUploader.new(user: scientist) }

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
      audit_action = AuditAction.new(AuditAction::MANIFEST_UPLOAD)
      labwares = Labware.where("barcode LIKE '%#{labware_prefix}%'")
      expect(labwares.first.audits.last.action).to eq(audit_action.key)
      expect(labwares.last.audits.last.action).to eq(audit_action.key)
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
      expect(manifest_uploader.errors.full_messages).to include("location(s) with barcode '#{new_location.barcode}' do not exist")
    end

    it 'will not create any labwares' do
      manifest_uploader.run
      labwares = Labware.where("barcode LIKE '%#{labware_prefix}%'")
      expect(labwares).to be_empty
    end
  end

  context 'when any of the locations are ordered' do
    let!(:manifest) { build(:csv_manifest, locations: locations + [ordered_location], number_of_labwares: 5, labware_prefix: labware_prefix).generate_csv }

    attr_reader :data

    before(:each) do
      manifest_uploader.file = manifest
    end

    it 'will not be valid' do
      expect(manifest_uploader).to_not be_valid
    end

    it 'will show an error' do
      manifest_uploader.run
      expect(manifest_uploader.errors.full_messages).to include("You are trying to put stuff into #{ordered_location.barcode} which is the wrong type")
    end
  end

  context 'when any of the data is invalid' do
    let!(:manifest) { build(:csv_manifest, locations: locations, number_of_labwares: 5, labware_prefix: labware_prefix).generate_csv }

    attr_reader :data

    context 'when there are empty cells' do
      before(:each) do
        manifest.concat(",\n")
        manifest_uploader.file = manifest
      end

      it 'will not be valid' do
        expect(manifest_uploader).to_not be_valid
      end

      it 'will show an error' do
        manifest_uploader.run
        expect(manifest_uploader.errors.full_messages).to include("It looks like there is some missing or invalid data. Please review and remove anything that shouldn't be there.")
      end
    end

    context 'when there is invalid data (length of cell string is < 5)' do
      before(:each) do
        manifest.concat("#{new_location.barcode},abcd\n")
        manifest_uploader.file = manifest
      end

      it 'will not be valid' do
        expect(manifest_uploader).to_not be_valid
      end

      it 'will show an error' do
        manifest_uploader.run
        expect(manifest_uploader.errors.full_messages).to include("It looks like there is some missing or invalid data. Please review and remove anything that shouldn't be there.")
      end
    end

    context 'when there are multiple empty cells' do
      before(:each) do
        manifest.concat("#{unordered_location.barcode},,\n")
        manifest.concat("#{unordered_location.barcode},,\n")
        manifest_uploader.file = manifest
      end

      it 'will not be valid' do
        expect(manifest_uploader).to_not be_valid
      end

      it 'will only show one error' do
        manifest_uploader.run
        expect(manifest_uploader.errors.full_messages).to eq(["It looks like there is some missing or invalid data. Please review and remove anything that shouldn't be there."])
      end
    end

    context 'when there are labwares with the same barcode as an existing location' do
      before(:each) do
        manifest.concat("#{unordered_location.barcode},#{unordered_location.barcode}\n")
        manifest_uploader.file = manifest
      end

      it 'will not be valid' do
        expect(manifest_uploader).to_not be_valid
      end

      it 'will only show one error' do
        manifest_uploader.run
        expect(manifest_uploader.errors.full_messages).to eq(["Labware barcodes cannot be the same as an existing location barcode. Please review and remove incorrect labware barcodes"])
      end
    end
  end

  context 'when the data is valid' do
    let!(:manifest) { build(:csv_manifest, locations: locations, number_of_labwares: 5, labware_prefix: labware_prefix).generate_csv }

    attr_reader :data

    context 'when there is valid data (length of cell string is >= 5)' do
      before(:each) do
        manifest.concat("#{unordered_location.barcode},abcde\n")
        manifest_uploader.file = manifest
      end

      it 'will not be valid' do
        expect(manifest_uploader).to be_valid
      end
    end
  end
end
