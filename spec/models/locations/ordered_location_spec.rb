require "rails_helper"

RSpec.describe OrderedLocation, type: :model do

  it "#populate should create correct number of coordinates from rows and columns" do
    location_1 = create(:ordered_location_with_parent, rows: 3, columns: 4)
    location_2 = create(:ordered_location_with_parent, rows: 1, columns: 1)

    Hash.grid(3,4) do |pos, row, col|
      expect(location_1.coordinates.find_by_position(position: pos)).to_not be_nil
      expect(location_1.coordinates.find_by_position(position: pos)).to eq(location_1.coordinates.find_by_position(row: row, column: col))
    end

    expect(location_2.coordinates.find_by_position(row: 2, column: 2)).to be_nil

  end

  context "#add_labware" do

    let!(:location)   { create(:ordered_location_with_parent, rows: 3, columns: 4) }
    let!(:labware_1)  { create(:labware) }
    let(:labware_2)   { build(:labware) }

    it "should add labware to a coordinate" do
   
      location.add_labware(barcode: labware_1.barcode, row: 1, column: 1)
      expect(location.reload.coordinates.find_by_position(row: 1, column: 1)).to be_filled
      expect(location.coordinates.find_by_position(row: 1, column: 1).labware).to eq(labware_1)

      location.add_labware(barcode: labware_2.barcode, position: 2)
      expect(location.coordinates.find_by_position(position: 2)).to be_filled
      expect(location.coordinates.find_by_position(position: 2).labware).to_not be_new_record
      expect(location.coordinates.find_by_position(position: 2).labware.location).to eq(location)
    end

    it "should fail silently if somebody is a bit free and easy with their arguments" do
      expect(location.add_labware(labware_1.barcode).compact).to be_empty
      expect(labware_1.coordinate).to be_empty
    end

    it "should fail silently if coordinate does not exist" do
      location.add_labware(barcode: labware_1.barcode, position: 999)
      expect(labware_1.coordinate).to be_empty

      location.add_labware(barcode: labware_2.barcode, position: 999)
      expect(Labware.find_by_barcode(labware_2.barcode)).to be_nil
    end

    it "should flush out any existing coordinates" do
      coordinate = create(:coordinate)
      coordinate.fill(labware_1)
      location.add_labware(barcode: labware_1.barcode, row: 1, column: 1)
      expect(coordinate.reload).to be_empty
    end

    it "should flush out any existing locations" do
      labware = create(:labware, location: create(:location_with_parent))
      location.add_labware(barcode: labware.barcode, row: 1, column: 1)
      expect(labware.reload.location).to eq(location)
    end

  end

  context "#add_labwares" do

    let!(:location) { create(:ordered_location_with_parent, rows: 3, columns: 4) }

    it "should add multiple labwares to a location" do
      attributes = [{barcode: build(:labware).barcode, position: 1},
                    {barcode: build(:labware).barcode, position: 2},
                    {barcode: build(:labware).barcode, position: 4},
                    {barcode: build(:labware).barcode, position: 999} ]
      location.add_labwares(attributes)
      expect(location.labwares.count).to eq(3)
      expect(location.coordinates.find_by_position(position: 1)).to be_filled
      expect(location.coordinates.find_by_position(position: 2)).to be_filled
      expect(location.coordinates.find_by_position(position: 3)).to_not be_filled
      expect(location.coordinates.find_by_position(position: 4)).to be_filled
    end

    it "should fail silently if somebody is a bit free and easy with their arguments" do
      labwares = create_list(:labware, 3)
      location.add_labwares(labwares.join_barcodes)
      expect(location.labwares).to be_empty
    end
    
  end

  it "#available_coordinates should return location if location is available" do
    location = create(:ordered_location_with_parent)
    locations = location.available_coordinates(10)
    expect(locations.length).to eq(1)
    expect(locations).to include(location)

    location = create(:ordered_location_with_labwares)
    expect(location.available_coordinates(10)).to be_empty
  end
  
end