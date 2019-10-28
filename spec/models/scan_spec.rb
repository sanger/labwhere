require "rails_helper"

RSpec.describe Scan, type: :model do
  let!(:location)          { create(:location_with_parent) }
  let!(:labwares)          { build(:labware_collection_unordered_location) }

  it "should correctly set the type based on the nature of the scan" do
    scan = create(:scan, location: location)
    expect(scan.in?).to be_truthy
    scan = create(:scan, location: nil)
    expect(scan.out?).to be_truthy
  end

  it "should provide a message to indicate the nature of the scan" do
    scan_1 = build(:scan)
    scan_1.add_attributes_from_collection(labwares)
    scan_1.save
    expect(scan_1.message).to eq("#{labwares.count} labwares scanned in to #{labwares.location.name}")

    scan_2 = create(:scan, location: nil)
    scan_2.labwares = labwares
    scan_2.save
    expect(scan_2.message).to eq("#{labwares.count} labwares scanned out from #{labwares.original_location_names}")
  end
end
