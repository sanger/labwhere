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
    location_1 = create(:location_with_parent)
    location_2 = create(:location_with_parent)
    location_3 = create(:location_with_parent)

    labware_1 = create(:labware, location: location_1)
    labware_2 = create(:labware, location: location_1)
    labware_3 = create(:labware, location: location_2)
    labware_4 = create(:labware, location: location_2)

    labware_1.update(location: location_2)
    labware_2.update(location: location_2)
    labware_3.update(location: location_3)

    expect(Labware.previous_locations(Labware.all)).to eq([location_1, location_2])
  end

  it "#update_previous_locations_counts should update the previous location counts" do
    location_1 = create(:location_with_parent)
    location_2 = create(:location_with_parent)

    labware_1 = create(:labware, location: location_1)
    labware_2 = create(:labware, location: location_1)
    labware_3 = create(:labware, location: location_1)
    
    labware_3.update(location: location_2)
    Labware.update_previous_location_counts(Labware.all)
    expect(location_1.reload.labwares_count).to eq(2)
  end

end
