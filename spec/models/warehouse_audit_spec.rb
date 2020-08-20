# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WarehouseAudit, type: :model do

  let(:user) { create(:user) }
  let(:location) { create(:unordered_location)}
  let(:labware) { create(:labware_with_location) }

  it 'must have a user' do
    expect(WarehouseAudit.new(labware: labware, action: 'scanned')).to_not be_valid
  end

  it 'must have a piece of labware' do
    expect(WarehouseAudit.new(user: user, action: 'scanned')).to_not be_valid
  end

  it 'must have a location' do
    expect(WarehouseAudit.new(user: user, labware: create(:labware), action: 'scanned')).to_not be_valid
  end

  it 'must have an action' do
    expect(WarehouseAudit.new(user: user, labware: labware)).to_not be_valid
  end

  it 'may have a coordinate'

  context 'for an unordered location' do

    it 'will produce the correct json for the message'

  end

  context 'for an ordered location' do

    it 'will produce the correct json for the message'

  end

end