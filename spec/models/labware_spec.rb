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

   it "#as_json should have the correct attributes" do
    labware = create(:labware)
    json = labware.as_json
    expect(json["created_at"]).to eq(labware.created_at.to_s(:uk))
    expect(json["updated_at"]).to eq(labware.updated_at.to_s(:uk))
    expect(json["location"]).to eq(labware.location.barcode)
    expect(json["location_id"]).to be_nil
    expect(json["coordinate_id"]).to be_nil
    expect(json["deleted_at"]).to be_nil
    expect(json["previous_location_id"]).to be_nil

  end

end
