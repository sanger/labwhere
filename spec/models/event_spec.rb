# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:labware) { create(:labware_with_location) }
  let(:audit) { create(:audit_of_labware, labware: labware) }
  let(:attributes) { { labware: labware, audit: audit } }
  let(:event) { Event.new(attributes) }

  # FOR A NEW AUDIT - NORMAL SCENARIO

  context 'for a new audit' do
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
              friendly_name: labware.location.barcode,
              uuid: labware.location.uuid
            }
          ],
          metadata: {
            location_coordinate: labware.coordinate.position,
            location_info: event.location_info
          }
        },
        lims: 'LABWHERE'
      }
    end

    it 'is valid' do
      expect(event).to be_valid
    end

    it 'creates a json with all the relevant bits of info' do
      expect(event.as_json).to eq(expected_json)
    end

    describe '#coordinate' do
      it 'returns a null coordinate' do
        expect(event.coordinate.class).to eq(NullCoordinate)
      end
    end

    context 'for an ordered location' do
      let!(:coordinate) { create(:coordinate, labware: labware, location: labware.location) }

      it 'is valid' do
        expect(event).to be_valid
      end

      it 'creates a json with all the relevant bits of info' do
        expect(event.as_json).to eq(expected_json)
      end

      describe '#coordinate' do
        it 'returns a coordinate' do
          expect(event.coordinate.class).to eq(Coordinate)
          expect(event.coordinate.position).to eq(coordinate.position)
        end
      end
    end

    it 'can tell it is not an old audit' do
      expect(event.for_old_audit?).to eq(false)
    end
  end

  # FOR AN OLD AUDIT - MIGRATIONS AND DATA PATCHES

  context 'for an old audit' do
    let(:location_1) { labware.location }
    let(:location_2) { create(:location_with_parent) }
    let(:audit_2) { create(:audit_of_labware, labware: labware) }

    before do
      # record the first location
      location_1
      # insert an audit for the labware
      audit
      # update location on labware
      labware.update!(location: location_2)
      # insert another audit for the labware
      audit_2
    end

    it 'is valid' do
      expect(event).to be_valid
    end

    it 'can tell it is an old audit' do
      expect(event.for_old_audit?).to eq(true)
    end

    context 'for an ordered location' do
      let!(:coordinate) { create(:coordinate, labware: labware, location: labware.location) }

      describe '#coordinate' do
        it 'does not return a coordinate as it is unknown' do
          expect(event.coordinate).to eq(nil)
        end
      end
    end

    context 'where the location still exists' do
      let(:expected_subject) do
        {
          role_type: 'location',
          subject_type: 'location',
          friendly_name: location_1.barcode,
          uuid: location_1.uuid
        }
      end

      it 'includes a location subject' do
        expect(event.as_json[:event][:subjects][1]).to eq(expected_subject)
      end

      it 'includes the parentage in the location info' do
        expect(event.location_info).to eq("#{location_1.parentage} - #{location_1.name}")
      end
    end

    context 'where the location has been deleted' do
      let!(:location_barcode) { location_1.barcode }

      before do
        location_1.destroy!
      end

      it 'is valid' do
        expect(event).to be_valid
      end

      it 'does not include a location subject as there is no uuid' do
        expect(event.as_json[:event][:subjects].length).to eq(1)
      end

      it 'just puts the barcode in the location info' do
        expect(event.location_info).to eq(location_barcode)
      end
    end

    context 'where the labware still exists' do
      let(:expected_subject) do
        {
          role_type: 'labware',
          subject_type: 'labware',
          friendly_name: labware.barcode,
          uuid: labware.uuid
        }
      end

      it 'includes a labware subject' do
        expect(event.as_json[:event][:subjects][0]).to eq(expected_subject)
      end
    end

    context 'where the labware has been deleted' do
      let!(:labware_barcode) { labware.barcode }
      let(:attributes) { { audit: audit } }

      let(:expected_subject) do
        {
          role_type: 'labware',
          subject_type: 'labware',
          friendly_name: labware.barcode,
          uuid: labware.uuid
        }
      end

      before do
        labware.destroy!
      end

      it 'is valid' do
        expect(event).to be_valid
      end

      it 'includes a labware subject' do
        expect(event.as_json[:event][:subjects][0]).to eq(expected_subject)
      end
    end
  end

  # FAILURE STATES

  context 'where required data is missing' do
    context 'where the location info is missing completely' do
      it 'fails validation' do
        audit.record_data.delete('location')
        expect(event).to_not be_valid
      end
    end

    context 'where the labware info is missing completely' do
      let(:attributes) { { audit: audit } }

      it 'fails validation' do
        audit.record_data.delete('barcode')
        expect(event).to_not be_valid
      end
    end

    context 'where the audit is missing' do
      let(:attributes) { { labware: labware } }

      it 'fails validation' do
        expect(event).to_not be_valid
      end
    end
  end
end
