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

  it "when it is added to scan should increase the events count" do
    labware = create(:labware)
    create(:scan, labwares: [labware])
    expect(labware.reload.histories_count).to eq(1)
    create(:scan, labwares: [labware])
    expect(labware.reload.histories_count).to eq(2)
  end

  it "locations should return a list of locations" do
    location1 = create(:location_with_parent)
    location2 = create(:location_with_parent)
    labware1 = create(:labware, location: location1)
    labware2 = create(:labware, location: location2)
    labware3 = create(:labware, location: location2)
    labwares = [labware1, labware2, labware3, build(:labware)]
    expect(Labware.locations(labwares)).to eq([location1, location2])
  end

  it "#previous_location should return previous location for the labware" do
    labware1 = build(:labware)
    labware2 = build(:labware)
    location1 = create(:location_with_parent)
    location2 = create(:location_with_parent)
    create(:scan, location: location1, labwares: [labware1, labware2])
    create(:scan, location: location2, labwares: [labware2])
    expect(labware1.reload.previous_location).to be_nil
    expect(labware2.reload.previous_location).to eq(location1)
  end

  it "#previous_locations should return previous locations for the labware" do
    labware1 = build(:labware)
    labware2 = build(:labware)
    labware3 = build(:labware)
    location1 = create(:location_with_parent)
    location2 = create(:location_with_parent)
    location3 = create(:location_with_parent)
    create(:scan, location: location1, labwares: [labware1, labware2, labware3])
    create(:scan, location: location2, labwares: [labware2, labware3])
    create(:scan, location: location2, labwares: [labware3])
    expect(Labware.previous_locations(Labware.all)).to eq([location1, location2])
  end

  it "#adding to a scan should set the correct number of labwares on the previous locations" do
    labware1 = build(:labware)
    labware2 = build(:labware)
    location1 = create(:location_with_parent)
    location2 = create(:location_with_parent)
    create(:scan, location: location1, labwares: [labware1, labware2])
    Labware.update_previous_location_counts([labware1, labware2])
    expect(location1.labwares_count).to eq(2)
    create(:scan, location: location2, labwares: [labware2])
    Labware.update_previous_location_counts([labware1, labware2])
    expect(location1.reload.labwares_count).to eq(1)
    expect(location2.reload.labwares_count).to eq(1)
  end

end
