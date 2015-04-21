require 'rails_helper'

RSpec.describe Scan, type: :model do

  it "if it has labwares then they should have the same location as the scan" do
    scan = create(:scan, location: create(:location_with_parent), labwares: build_list(:labware, 5))
    expect(scan.labwares.count).to eq(5)
    expect( scan.labwares.all? { |labware| labware.location == scan.location }).to be_truthy
  end

end
