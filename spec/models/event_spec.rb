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
    it 'adds a prefix, replaces spaces with underscores, and changes to lower case' do
      expect(Event.generate_event_type('Uploaded from manifest')).to eq('labwhere_uploaded_from_manifest')
    end
  end

  describe '#location_info' do
    it 'concatenates location parentage and name' do
      location = create(:location_with_parent)
      expect(Event.location_info(location)).to eq("#{location.parentage} - #{location.name}")
    end

    it 'returns just the name if the parentage is blank' do
      location = create(:location)
      expect(Event.location_info(location)).to eq(location.name)
    end
  end

  context 'for an unordered location' do
    let(:location) { create(:unordered_location_with_parent) }
    let(:labware) { create(:labware, location: location) }
    let(:expected_json) do
      {
        event: {
          uuid: audit.uuid,
          event_type: "labwhere_create",
          occured_at: audit.created_at,
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
            location_coordinate: labware.coordinate.position,
            location_info: Event.location_info(location)
          }
        },
        lims: 'LABWHERE'
      }
    end

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

      expect(json[:event][:subjects][1][:friendly_name]).to eq(locn.barcode)
      expect(json[:event][:metadata][:location_coordinate]).to eq(coordinate.position)
    end
  end
end
