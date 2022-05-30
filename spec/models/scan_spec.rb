# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scan, type: :model do
  let!(:location)          { create(:location_with_parent) }
  let!(:labwares)          { build(:labware_collection_unordered_location) }

  it 'should correctly set the type based on the nature of the scan' do
    scan = create(:scan, location: location)
    expect(scan.in?).to be_truthy
    scan = create(:scan, location: nil)
    expect(scan.out?).to be_truthy
  end

  it 'should provide a message to indicate the nature of the scan' do
    scan1 = build(:scan)
    scan1.add_attributes_from_collection(labwares)
    scan1.save
    expect(scan1.message).to eq("#{labwares.count} labwares scanned in to #{labwares.location.name}")

    scan2 = create(:scan, location: nil)
    scan2.labwares = labwares
    scan2.save
    expect(scan2.message).to eq("#{labwares.count} labwares scanned out from #{labwares.original_location_names}")
  end
end
