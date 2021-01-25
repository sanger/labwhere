# frozen_string_literal: true

require "rails_helper"

RSpec.describe LabwareCollection, type: :model do
  let!(:previous_location1)    { create(:location_with_parent) }
  let!(:previous_location2)    { create(:location_with_parent) }
  let!(:labwares1)             { create_list(:labware, 5, location: previous_location1) }
  let!(:labwares2)             { create_list(:labware, 5, location: previous_location2) }
  let(:new_labwares)            { build_list(:labware, 5) }
  let(:labwares)                { labwares1 + labwares2 + new_labwares }
  let!(:administrator) { create(:administrator) }

  describe 'adding to an unordered location' do
    let!(:location)           { create(:location_with_parent) }
    let(:labware_collection)  { LabwareCollection.open(location: location, user: administrator, labwares: labwares.extract_barcodes) }

    it "creates the correct number of labwares" do
      expect(labware_collection.count).to eq(labwares.count)
    end

    it "adds each of the labwares to the location" do
      labware_collection.push
      expect(location.labwares.count).to eq(labware_collection.count)
    end

    it "provides a list of the original locations for the labware" do
      labware_collection.push
      expect(labware_collection.original_location_names).to eq("#{previous_location1.name}, #{previous_location2.name}")
    end

    it "creates an audit record for each labware" do
      labware_collection.push
      location.labwares.each do |labware|
        expect(labware.audits.count).to eq(1)
      end
    end

    it 'removes duplicates from labwares which have been passed' do
      labware_collection = LabwareCollection.open(location: location, user: administrator, labwares: new_labwares.extract_barcodes + new_labwares.extract_barcodes)
      expect(labware_collection.count).to eq(new_labwares.count)
      labware_collection.push
      expect(location.labwares.count).to eq(new_labwares.count)
    end
  end

  describe 'adding to an ordered location with a starting position' do
    let!(:location) { create(:ordered_location_with_parent, rows: 5, columns: 5) }

    it "adds labwares to the correct coordinates if a starting position is added" do
      labware_collection = LabwareCollection.open(location: location, user: administrator, labwares: labwares.extract_barcodes, start_position: 5)
      labware_collection.push
      expect(location.labwares.count).to eq(labware_collection.count)
      ((labware_collection.start_position)..(labware_collection.start_position + labware_collection.count - 1)).each do |i|
        expect(location.coordinates.find_by_position(position: i)).to be_filled
      end
    end

    it "allows coordinates to be passed" do
      coordinates = location.available_coordinates(5, labwares.count)
      labware_collection = LabwareCollection.open(location: location, user: administrator, labwares: labwares.extract_barcodes, coordinates: coordinates)
      labware_collection.push
      expect(location.labwares.count).to eq(labware_collection.count)
    end

    it "adds labwares to the correct coordinates if some of the coordinates are already filled" do
      location.coordinates.find_by_position(position: 6).fill(create(:labware))
      labware_collection = LabwareCollection.open(location: location, user: administrator, labwares: labwares.extract_barcodes, start_position: 5)
      labware_collection.push
      expect(location.labwares.count).to eq(labware_collection.count + 1)
      ((labware_collection.start_position)..(labware_collection.start_position + labware_collection.count)).each do |i|
        expect(location.coordinates.find_by_position(position: i)).to be_filled
      end
    end

    it "fails if the position runs over the end of the available coordinates" do
      labware_collection = LabwareCollection.open(location: location, user: administrator, labwares: labwares.extract_barcodes, start_position: 20)
      expect(labware_collection).to_not be_valid
      labware_collection.push
      expect(location.labwares).to be_empty
    end

    it 'removes duplicates from labwares which have been passed' do
      labware_collection = LabwareCollection.open(location: location, user: administrator, labwares: new_labwares.extract_barcodes + new_labwares.extract_barcodes, start_position: 5)
      expect(labware_collection.count).to eq(new_labwares.count)
      labware_collection.push
      ((labware_collection.start_position)..(labware_collection.start_position + labware_collection.count - 1)).each do |i|
        expect(location.coordinates.find_by_position(position: i)).to be_filled
      end
    end
  end
end
