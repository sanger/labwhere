require "rails_helper"

RSpec.describe LabwareCollection, type: :model do

  let!(:previous_location_1)    { create(:location_with_parent)}
  let!(:previous_location_2)    { create(:location_with_parent)}
  let!(:labwares_1)             { create_list(:labware, 5, location: previous_location_1) }
  let!(:labwares_2)             { create_list(:labware, 5, location: previous_location_2) }
  let(:new_labwares)            { build_list(:labware, 5)}
  let(:labwares)                { labwares_1 + labwares_2 + new_labwares}
  let!(:user)                   { create(:administrator)}

  describe 'adding to an unordered location' do

    let!(:location)           { create(:location_with_parent) }
    let(:labware_collection)  { LabwareCollection.new(location, user, labwares.join_barcodes)}

    it "should create the correct number of labwares" do
      expect(labware_collection.count).to eq(labwares.count)
    end

    it "should add each of the labwares to the location" do
      labware_collection.push
      expect(location.labwares.count).to eq(labware_collection.count)
    end

    it "should provide a list of the original locations for the labware" do
      labware_collection.push
      expect(labware_collection.original_location_names).to eq(previous_location_1.name + ", " + previous_location_2.name)
    end

    it "should create an audit record for each labware" do
      labware_collection.push
      location.labwares.each do |labware|
        expect(labware.audits.count).to eq(1)
      end
    end

  end

  describe 'adding to an ordered location' do
    let!(:location)           { create(:ordered_location_with_parent, rows: 3, columns: 4)}
    let(:labwares_array)      {  [ ActionController::Parameters.new(barcode: labwares_1.first.barcode, position: 1),
                                  ActionController::Parameters.new(barcode: new_labwares.first.barcode, position: 4),
                                  ActionController::Parameters.new(barcode: labwares_2.first.barcode, row: 3, column: 4) ] }
    let(:labware_collection)  { LabwareCollection.new(location, user, labwares_array)}

    it "should create the correct number of labwares" do
      expect(labware_collection.count).to eq(labwares_array.count)
    end

    it "should add each of the labwares to the location" do
      labware_collection.push
      expect(location.labwares.count).to eq(labware_collection.count)
      expect(location.coordinates.find_by_position(position: 1).labware.barcode).to eq(labwares_1.first.barcode)
      expect(location.coordinates.find_by_position(position: 4).labware.barcode).to eq(new_labwares.first.barcode)
      expect(location.coordinates.find_by_position(row: 3, column: 4).labware.barcode).to eq(labwares_2.first.barcode)
    end

    it "should provide a list of the original locations for the labware" do
      labware_collection.push
      expect(labware_collection.original_location_names).to eq(previous_location_1.name + ", " + previous_location_2.name)
    end

     it "should create an audit record for each labware" do
      labware_collection.push
      location.labwares.each do |labware|
        expect(labware.audits.count).to eq(1)
      end
    end


  end


end