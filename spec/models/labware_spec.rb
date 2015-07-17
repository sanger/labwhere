require 'rails_helper'

RSpec.describe Labware, type: :model do
  it "is invalid without a barcode" do
    expect(build(:labware, barcode: nil)).to_not be_valid
  end

  it "is invalid without a unique barcode" do
    labware = create(:labware)
    expect(build(:labware, barcode: labware.barcode)).to_not be_valid
  end

  it "can only be added to a location that is nested" do
    expect(build(:labware, location: build(:location))).to_not be_valid
    expect(build(:labware, location: build(:location_with_parent))).to be_valid
  end

  it "can be added to a location that is unknown" do
    expect(build(:labware, location: Location.unknown)).to be_valid
  end

  it "is destroyed it will be soft deleted with all associations removed" do
    labware = create(:labware, location: create(:location_with_parent))
    labware.destroy
    expect(Labware.deleted.count).to eq(1)
    expect(labware.reload.location.unknown?).to be_truthy
  end

  it "is created with no location should set location to be unknown" do
    labware = create(:labware)
    expect(labware.location.unknown?).to be_truthy
  end

  it "when the location is updated should update the previous_location" do
    location_1 = create(:location_with_parent)
    location_2 = create(:location_with_parent)
    labware = create(:labware, location: location_1)
    expect(labware.previous_location).to be_nil
    labware.update(location: location_2)
    expect(labware.previous_location).to eq(location_1)
  end

  it "#previous_locations should return a unique list of the previous locations for some Labware" do
    locations = create_list(:location_with_parent, 3)
    labwares_1 = create_list(:labware, 2, location: locations.first)
    labwares_2 = create_list(:labware, 2, location: locations.second)

    labwares_1.first.update(location: locations.second)
    labwares_1.last.update(location: locations.second)
    labwares_2.first.update(location: locations.last)

    expect(Labware.previous_locations(Labware.all)).to eq([locations.first, locations.second])
  end

  it "#build_for should find or initialize labware for associated object for a string of labware barcodes" do
    existing_labwares = create_list(:labware, 2, location: create(:location_with_parent))
    new_labwares = build_list(:labware, 2)
    scan = build(:scan)
    Labware.build_for(scan, existing_labwares.join_barcodes+"\n"+new_labwares.join_barcodes)
    expect(scan.labwares.length).to eq(4)
  end

  it "#build_for should find or initialize labware for associated object for a hash of labwares" do
    existing_labware_1 = create(:labware, location: create(:location_with_parent))
    existing_labware_2 = create(:labware, location: create(:location_with_parent))
    new_labware_1 = attributes_for(:labware)
    new_labware_2 = attributes_for(:labware)

    labwares = [  {barcode: existing_labware_1.barcode},
                  {barcode: existing_labware_2.barcode},
                  new_labware_1, 
                  new_labware_2]

    scan = build(:scan)
    Labware.build_for(scan, labwares)
    expect(scan.labwares.length).to eq(4)
    expect(scan.labwares.all? { |labware| labware.new_record?}).to be_falsey
  end

  it "#find_by_code should find labware by barcode" do
    labware = create(:labware)
    expect(Labware.find_by_code(labware.barcode)).to eq(labware)
  end

  it "#by_barcode should return a list of labwares for the barcodes" do
    create_list(:labware, 5)
    expect(Labware.by_barcode(Labware.pluck(:barcode)).count).to eq(5)
  end

  it "#location should always be returned whether labware is attached to a location, coordinate or nothing" do
    location = create(:location_with_parent)
    coordinate = create(:coordinate)
    labware_1 = create(:labware, location: location)
    expect(labware_1.location).to eq(location)
    labware_2 = create(:labware, coordinate: coordinate)
    expect(labware_2.location).to eq(coordinate.location)
    labware_3 = create(:labware)
    expect(labware_3.location).to be_unknown
  end

end
