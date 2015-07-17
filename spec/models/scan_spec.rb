require "rails_helper"

RSpec.describe Scan, type: :model do

  let!(:location)             { create(:location_with_parent)}
  let!(:other_location)     { create(:location_with_parent)}
  let!(:labwares)         { create_list(:labware, 4, previous_location: other_location, location: location)}

  it "should correctly set the type based on the nature of the scan" do
    scan = create(:scan, location: location)
    expect(scan.in?).to be_truthy
    scan = create(:scan, location: nil)
    expect(scan.out?).to be_truthy
  end

  it "should provide a message to indicate the nature of the scan" do
    scan_1 = create(:scan, location: location)
    scan_1.create_message(labwares)
    expect(scan_1.message).to eq("#{labwares.count} labwares scanned in to #{scan_1.location.name}")

    scan_2 = create(:scan, location: nil)
    scan_2.create_message(labwares)
    expect(scan_2.message).to eq("#{labwares.count} labwares scanned out from #{other_location.name}")
  end

end