# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:user) { create(:user) }
  let(:labware) { create(:labware_with_location) }
  let(:action) { 'scanned' }
  let(:attributes) { { user: user, labware: labware, action: action } }

  it 'must have a user' do
    expect(Event.new(attributes.except(:user))).to_not be_valid
  end

  it 'must have a piece of labware' do
    expect(Event.new(attributes.except(:labware))).to_not be_valid
  end

  it 'must have a location' do
    expect(Event.new(attributes.merge(labware: create(:labware)))).to_not be_valid
  end

  it 'must have an action' do
    expect(Event.new(attributes.except(:action))).to_not be_valid
  end

  it 'may have a coordinate' do
    coordinate = create(:coordinate, labware: create(:labware))
    audit = Event.new(attributes.merge(labware: coordinate.labware))
    expect(audit.coordinate).to be_present
  end

  context 'for an unordered location' do
    let(:location) { create(:unordered_location_with_parent) }
    let(:labware) { create(:labware, location: location) }

    it 'will produce the correct json for the message' do
      audit = Event.new(user: user, labware: labware, action: action)
      json = audit.as_json
      expect(json[:location_barcode]).to eq(location.barcode)
      expect(json[:location_name]).to eq(location.name)
      expect(json[:parentage]).to eq(location.parentage)
      expect(json[:labware_barcode]).to eq(labware.barcode)
      expect(json[:action]).to eq(action)
      expect(json[:user_login]).to eq(user.login)
      expect(json[:coordinates]).to be_nil
    end
  end

  context 'for an ordered location' do
    coordinate = create(:coordinate, labware: create(:labware))

    it 'will produce the correct json for the message' do
      location = coordinate.labware.location
      audit = Event.new(attributes.merge(labware: coordinate.labware))
      json = audit.as_json
      expect(json[:location_barcode]).to eq(location.barcode)
      expect(json[:coordinate]).to eq(coordinate.position)
    end
  end
end
