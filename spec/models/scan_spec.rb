require "rails_helper"

RSpec.describe Scan, type: :model do

  let!(:location)             { create(:location_with_parent)}
  let!(:other_location)     { create(:location_with_parent)}
  let(:new_labwares)         { build_list(:labware, 4)}

  it "should correctly update the labware count when new labwares are added to a location" do
    create(:scan, location: location, labwares: new_labwares)
    expect(location.reload.labwares_count).to eq(4)
  end

  it "should correctly update the labware count when labwares are removed from a location" do
    create(:scan, location: location, labwares: new_labwares)
    create(:scan, location: nil, labwares: new_labwares)
    expect(location.reload.labwares_count).to eq(0)
    expect(Location.unknown.labwares_count).to eq(4)
  end

  it "should correctly update the labware count when labwares are moved to another location" do
    create(:scan, location: other_location, labwares: new_labwares)
    expect(other_location.reload.labwares_count).to eq(4)
    create(:scan, location: location, labwares: new_labwares)
    expect(other_location.reload.labwares_count).to eq(0)
    expect(location.reload.labwares_count).to eq(4)
  end

  it "should correctly set the type based on the nature of the scan" do
    scan = create(:scan, location: location, labwares: new_labwares)
    expect(scan.in?).to be_truthy
    scan = create(:scan, location: nil, labwares: new_labwares)
    expect(scan.out?).to be_truthy
  end

  it "should provide a message to indicate the nature of the scan" do
    scan = create(:scan, location: location, labwares: new_labwares)
    expect(scan.message).to eq("#{scan.labwares.count} labwares scanned in to #{scan.location.name}")
    labwares = scan.labwares
    locations = Labware.locations(scan.labwares)
    scan = create(:scan, location: nil, labwares: labwares)
    expect(scan.message).to eq("#{scan.labwares.count} labwares scanned out from #{Location.names(locations)}")
  end


end