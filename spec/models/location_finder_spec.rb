# frozen_string_literal: true

require 'rails_helper'
require 'csv'

def create_csv(labwares)
  CSV.generate do |csv|
    labwares.each do |labware|
      csv << [labware.barcode]
    end
  end
end

RSpec.describe LocationFinder, type: :model do
  let!(:labwares) { create_list(:labware_with_location, 10) }
  let!(:labware_with_no_location) { create(:labware) }
  let(:null_location) { NullLocation.new }

  it 'will work' do
    expect(true).to be_truthy
  end

  it 'will only be valid if there is a single column' do
    dodgy_csv = "bish,bash,bosh\n#{create_csv(labwares)}"
    location_finder = LocationFinder.new(file: dodgy_csv)
    expect(location_finder).to_not be_valid
  end

  describe 'when everything is valid' do
    let(:csv) { create_csv(labwares) }
    let(:location_finder) { LocationFinder.new(file: csv) }

    it 'should have the correct number of locations' do
      location_finder.run
      expect(location_finder.results.length).to eq(10)
    end

    it 'should have the barcode for each labware' do
      location_finder.run
      keys = location_finder.results.keys
      expect(keys.first).to eq(labwares.first.barcode)
      expect(keys.last).to eq(labwares.last.barcode)
    end

    it 'should have the correct labwares' do
      location_finder.run
      labware = location_finder.results[labwares.first.barcode]
      expect(labware).to eq(labwares.first)

      labware = location_finder.results[labwares.last.barcode]
      expect(labware).to eq(labwares.last)
    end
  end

  describe 'when one of the labwares does not have a location' do
    let(:csv) { create_csv(labwares + [labware_with_no_location]) }
    let(:location_finder) { LocationFinder.new(file: csv) }

    it 'should still have a record for the empty location' do
      location_finder.run
      expect(location_finder.results.length).to eq(11)
    end

    it 'should have some data to signify it is an empty location' do
      location_finder.run
      null_location = NullLocation.new

      labware = location_finder.results[labware_with_no_location.barcode]

      expect(labware.location).to eq(null_location)
    end
  end

  describe 'when one of the labwares does not exist' do
    let(:dodgy_labware) { build(:labware) }
    let(:csv) { create_csv(labwares + [dodgy_labware]) }
    let(:location_finder) { LocationFinder.new(file: csv) }
    let(:null_labware) { NullLabware.new }

    it 'should still have a record' do
      location_finder.run
      expect(location_finder.results[dodgy_labware.barcode]).to be_defined
    end

    it 'should show the labware as empty' do
      location_finder.run
      expect(location_finder.results[dodgy_labware.barcode]).to eq(null_labware)
    end
  end

  describe 'when there is dodgy data' do
    it 'when there are blank lines' do
      csv = create_csv(labwares)
      csv.concat("\n")

      location_finder = LocationFinder.new(file: csv)
      location_finder.run

      expect(location_finder.results.length).to eq(labwares.length)
    end

    it 'when there are duplicate barcodes' do
      csv = create_csv(labwares + [labwares.last])
      location_finder = LocationFinder.new(file: csv)
      location_finder.run
      expect(location_finder.results.length).to eq(labwares.length)
    end
  end

  describe 'creating the csv' do
    context 'when all of the labwares exist' do
      let!(:csv)             { create_csv(labwares) }
      let!(:location_finder) do
        location_finder = LocationFinder.new(file: csv)
        location_finder.run
        location_finder
      end
      let!(:csv_output)             { CSV.parse(location_finder.csv) }
      let(:labware_first)           { labwares.first }
      let(:labware_last)            { labwares.last }
      let(:labware_record_first)    { csv_output.select { |row| row[0] == labware_first.barcode }.flatten }
      let(:labware_record_last)     { csv_output.select { |row| row[0] == labware_last.barcode }.flatten }

      it 'will have the correct headers' do
        expect(csv_output[0]).to eq(%w[labware_barcode labware_exists location_barcode location_name location_parentage])
      end

      it 'will have the correct number of rows' do
        expect(csv_output.length).to eq(11)
      end

      it 'will have the original labware barcode for each row' do
        expect(labware_record_first[0]).to eq(labware_first.barcode)
        expect(labware_record_last[0]).to eq(labware_last.barcode)
      end

      it 'will indicate whether the labware exists' do
        expect(labware_record_first[1]).to eq(labware_first.exists)
        expect(labware_record_last[1]).to eq(labware_last.exists)
      end

      it 'will have the location barcode for each row' do
        expect(labware_record_first[2]).to eq(labware_first.location.barcode)
        expect(labware_record_last[2]).to eq(labware_last.location.barcode)
      end

      it 'will have the location name for each row' do
        expect(labware_record_first[3]).to eq(labware_first.location.name)
        expect(labware_record_last[3]).to eq(labware_last.location.name)
      end

      it 'will have the location parentage for each row' do
        expect(labware_record_first[4]).to eq(labware_first.location.parentage)
        expect(labware_record_last[4]).to eq(labware_last.location.parentage)
      end
    end

    context 'when any of the labwares do not exist' do
      let(:unknown_labware)  { build(:labware) }
      let(:csv) { create_csv(labwares + [unknown_labware]) }
      let!(:location_finder) do
        location_finder = LocationFinder.new(file: csv)
        location_finder.run
        location_finder
      end
      let(:csv_output)        { CSV.parse(location_finder.csv) }
      let(:labware_record)    { csv_output.select { |row| row[0] == unknown_labware.barcode }.flatten }
      let(:null_labware)      { NullLabware.new }

      it 'will have the correct number of rows' do
        expect(csv_output.length).to eq(12)
      end

      it 'will have the original labware barcode for each row' do
        expect(labware_record[0]).to eq(unknown_labware.barcode)
      end

      it 'will state that the labware is not found for a row where the labware does not exist' do
        expect(labware_record[1]).to eq(null_labware.exists)
      end

      it 'will state that the location does not exist where the labware does not exist' do
        expect(labware_record[2]).to eq(null_labware.location.barcode)
      end
    end

    context 'when any of the locations do not exist' do
      let(:csv) { create_csv(labwares + [labware_with_no_location]) }
      let!(:location_finder) do
        location_finder = LocationFinder.new(file: csv)
        location_finder.run
        location_finder
      end
      let(:csv_output)        { CSV.parse(location_finder.csv) }
      let(:null_location)     { NullLocation.new }
      let(:labware_record)    { csv_output.select { |row| row[0] == labware_with_no_location.barcode }.flatten }

      it 'will have the correct number of rows' do
        expect(csv_output.length).to eq(12)
      end

      it 'will have the original labware barcode for each row' do
        expect(labware_record[0]).to eq(labware_with_no_location.barcode)
      end

      it 'will state that the location does not exist for a row where the labware has not location' do
        expect(labware_record[2]).to eq(null_location.barcode)
      end
    end
  end
end
