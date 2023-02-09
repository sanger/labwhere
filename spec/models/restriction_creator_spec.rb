# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RestrictionCreator, type: :model do
  let!(:site) { create(:location_type, name: 'Site') }
  let!(:building) { create(:location_type, name: 'Building') }
  let!(:room) { create(:location_type, name: 'Room') }
  let!(:delivered) { create(:location_type, name: 'Delivered') }
  let!(:tray) { create(:location_type, name: 'Tray') }
  let!(:bin) { create(:location_type, name: 'Bin') }
  let!(:fridge) { create(:location_type, name: 'Fridge') }
  let!(:site_parent) { create(:location, location_type: site) }
  let!(:building_parent) { create(:location, location_type: building) }
  let!(:room_parent) { create(:location, location_type: room) }
  let!(:yaml) { YAML.load_file(Rails.root.join('app/data/restrictions.yaml')) }

  before(:each) do
    RestrictionCreator.new(yaml).run!
  end

  it 'Empty parent restriction should ensure location has no parent' do
    site.reload
    expect(build(:location, name: 'Site1', location_type: site)).to be_valid
    expect(build(:location, name: 'Site2', location_type: site, parent: create(:location))).to_not be_valid
  end

  it 'uniqueness restriction should ensure location can only have a single occurrence of a name' do
    create(:location, name: 'A building', location_type: building)
    expect(build(:location, name: 'A building', location_type: building)).to_not be_valid
  end

  # had to split this test and following one out as there was a failure
  # not sure what is going on
  # really like the restriction validators so might be worth a bit
  # more investigation
  it 'Allow list parent restriction should ensure location has a parent of a type indicated
    in an allow list for site' do
    building.reload
    expect(build(:location, name: 'Building1', location_type: building, parent: site_parent)).to be_valid
  end

  it 'Allow list parent restriction should ensure location has a parent of a type indicated
    in an allow list for room' do
    building.reload
    expect(build(:location, name: 'Building2', location_type: building, parent: room_parent)).to_not be_valid
  end

  it "Deny list parent restriction should ensure location does not have a parent
    of a type indicated in a deny list" do
    expect(build(:location, name: 'Fridge1', location_type: fridge, parent: site_parent)).to_not be_valid
    expect(build(:location, name: 'Fridge1', location_type: fridge, parent: building_parent)).to_not be_valid
    expect(build(:location, name: 'Fridge2', location_type: fridge, parent: room_parent)).to be_valid
  end

  it 'should have correct restrictions for locations of types tray, bin, delivered' do
    expect(build(:location, name: 'Tray1', location_type: tray, parent: site_parent)).to_not be_valid
    expect(build(:location, name: 'Tray2', location_type: tray, parent: building_parent)).to be_valid
    expect(build(:location, name: 'Bin1', location_type: bin, parent: site_parent)).to_not be_valid
    expect(build(:location, name: 'Bin2', location_type: bin, parent: building_parent)).to be_valid
    expect(build(:location, name: 'Delivered1', location_type: delivered, parent: site_parent)).to be_valid
    expect(build(:location, name: 'Delivered2', location_type: delivered, parent: building_parent)).to be_valid
    # delivered can now have any parent, updated from only allowed building parent
  end
end
