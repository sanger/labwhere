# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:labware) { create(:labware_with_location) }
  let(:audit) { create(:audit) }
  let(:attributes) { { labware: labware, audit: audit } }

  it 'must have a piece of labware' do
    expect(Event.new(attributes.except(:labware))).to_not be_valid
  end

  it 'must have a location' do
    expect(Event.new(attributes.merge(labware: create(:labware)))).to_not be_valid
  end

  it 'may have a coordinate' do
    coordinate = create(:coordinate, labware: create(:labware))
    event = Event.new(attributes.merge(labware: coordinate.labware))
    expect(event.coordinate).to be_present
  end

  describe '#generate_event_type' do
    it 'adds a prefix and replaces spaces with underscores' do
      expect(Event.generate_event_type('Uploaded from manifest')).to eq('lw_Uploaded_from_manifest')
    end
  end

  context 'for an unordered location' do
    let(:location) { create(:unordered_location_with_parent) }
    let(:labware) { create(:labware, location: location) }
    let(:date_time) { Time.zone.now }
    let(:expected_json) do
      {
        event: {
          uuid: audit.uuid,
          event_type: "lw_create",
          occured_at: date_time,
          user_identifier: audit.user.login,
          subjects: [
            {
              role_type: 'labware',
              subject_type: 'labware',
              friendly_name: labware.barcode,
              uuid: labware.uuid
            },
            {
              role_type: 'location',
              subject_type: 'location',
              friendly_name: location.barcode,
              uuid: location.uuid
            }
          ],
          metadata: {
            location_barcode: location.barcode,
            location_coordinate: labware.coordinate.position,
            location_name: location.name,
            location_parentage: location.parentage
          }
        },
        lims: 'LABWHERE'
      }
    end

    before { allow(Time.zone).to receive(:now).and_return(date_time) }

    it 'will produce the correct json for the message' do
      event = Event.new(labware: labware, audit: audit)
      json = event.as_json
      expect(json).to eq(expected_json)
    end
  end

  context 'for an ordered location' do
    let(:coordinate) { create(:coordinate, labware: create(:labware)) }

    it 'will produce the correct json for the message' do
      locn = coordinate.labware.location
      event = Event.new(attributes.merge(labware: coordinate.labware))
      json = event.as_json

      expect(json[:event][:metadata][:location_barcode]).to eq(locn.barcode)
      expect(json[:event][:metadata][:location_coordinate]).to eq(coordinate.position)
    end
  end
end
