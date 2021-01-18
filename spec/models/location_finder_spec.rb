# frozen_string_literal: true

require 'rails_helper'
require 'csv'

def create_csv(labwares)
  CSV.generate do |csv|
    # csv << ['Labware']
    labwares.each do |labware|
      csv << [labware.barcode]
    end
  end
end

RSpec.describe LocationFinder, type: :model do

  let!(:labwares)                  { create_list(:labware_with_location, 10) }
  let!(:labware_with_no_location ) { create(:labware) }
  let(:null_location)              { NullLocation.new }

  it 'will work' do
    expect(true).to be_truthy
  end

  describe 'when everything is valid' do

    let(:csv) { create_csv(labwares) }
    let(:location_finder) { LocationFinder.new(file: csv) }

    it 'should have the correct number of locations' do
      expect(location_finder.results.length).to eq(10)
    end

    it 'should have the barcode for each labware' do
      keys = location_finder.results.keys
      expect(keys.first).to eq(labwares.first.barcode)
      expect(keys.last).to eq(labwares.last.barcode)
    end

    it 'should have the correct labwares' do
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
      expect(location_finder.results.length).to eq(11)
    end

    it 'should have some data to signify it is an empty location' do
      
      null_location = NullLocation.new

      labware = location_finder.results[labware_with_no_location.barcode]

      expect(labware.location).to eq(null_location)
    end
  end

  describe 'when one of the labwares does not exist' do
    
    let(:dodgy_labware) {build(:labware) }
    let(:csv) { create_csv(labwares + [dodgy_labware]) }
    let(:location_finder) { LocationFinder.new(file: csv) }
    let(:null_labware) { NullLabware.new }

    it 'should still have a record' do
      expect(location_finder.results[dodgy_labware.barcode]).to be_defined
    end

    it 'should show the labware as empty' do
      expect(location_finder.results[dodgy_labware.barcode]).to eq(null_labware)
    end
  end

  describe 'when there is dodgy data' do
    
    it 'when there are blank lines' do
      csv = create_csv(labwares)
      csv.concat("\n")

      location_finder = LocationFinder.new(file: csv)

      expect(location_finder.results.length).to eq(labwares.length)
    end

    it 'when there are duplicate barcodes' do
      csv = create_csv(labwares + [labwares.last])
      location_finder = LocationFinder.new(file: csv)
      expect(location_finder.results.length).to eq(labwares.length)
    end
  end

end
