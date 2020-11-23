# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:labware) { create(:labware_with_location) }
  let(:audit) { create(:audit_of_labware, labware: labware) }
  let(:attributes) { { labware: labware, audit: audit } }

  it 'must have a piece of labware' do
    expect(Event.new(attributes.except(:labware))).to_not be_valid
  end

  context 'without a location' do
    let(:labware) { create(:labware) }

    it 'is invalid' do
      expect(Event.new(attributes)).to_not be_valid
    end
  end

  context 'with a coordinate' do
    let!(:coordinate) { create(:coordinate, labware: labware, location: labware.location) }

    it 'returns the coordinate' do
      event = Event.new(attributes)
      expect(event.coordinate).to be_present
    end
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
      event = Event.new(attributes)
      json = event.as_json
      expect(json).to eq(expected_json)
    end
  end

  context 'for an ordered location' do
    let!(:coordinate) { create(:coordinate, labware: labware, location: labware.location) }

    it 'will produce the correct json for the message' do
      locn = labware.location
      event = Event.new(attributes)
      json = event.as_json

      expect(json[:event][:subjects][1][:friendly_name]).to eq(locn.barcode)
      expect(json[:event][:metadata][:location_coordinate]).to eq(coordinate.position)
    end
  end

  context 'creating an event for an old audit' do
    context 'where the location has changed since' do
      let(:first_location) { labware.location }
      let(:second_location) { create(:location_with_parent) }

      before do
        # preload things
        first_location
        audit
        # change the location on the labware
        labware.update!(location: second_location)
      end

      it 'uses the location from the time the audit was created' do
        event = Event.new(attributes)

        expect(first_location.id).to_not eq(second_location.id) # sanity check
        expect(event.location.id).to eq(first_location.id)
      end
    end

    context 'where the coordinate has changed since' do
      let(:first_coordinate) { create(:coordinate, labware: labware, location: labware.location) }
      let(:second_coordinate) { create(:coordinate, labware: labware, location: labware.location) }
      let(:second_audit) { create(:audit_of_labware, labware: labware) }

      before do
        # preload things
        first_coordinate
        audit
        # change the coordinate on the labware
        second_coordinate
        second_audit
      end

      it 'uses the coordinate from the time the audit was created' do
        event = Event.new(attributes)

        expect(first_coordinate.id).to_not eq(second_coordinate.id) # sanity check
        expect(event.coordinate).to eq(nil)
      end
    end
  end
end
