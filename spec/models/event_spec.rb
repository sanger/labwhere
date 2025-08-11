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
          event_type: 'labwhere_create',
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
    let(:location1) { labware.location }
    let(:location2) { create(:location_with_parent) }
    let(:audit2) { create(:audit_of_labware, labware: labware) }

    before do
      # record the first location
      location1
      # insert an audit for the labware
      audit
      # update location on labware
      labware.update!(location: location2)
      # insert another audit for the labware
      audit2
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
          friendly_name: location1.barcode,
          uuid: location1.uuid
        }
      end

      it 'includes a location subject' do
        expect(event.as_json[:event][:subjects][1]).to eq(expected_subject)
      end

      it 'includes the parentage in the location info' do
        expect(event.location_info).to eq("#{location1.parentage} - #{location1.name}")
      end
    end

    context 'where the location has been deleted' do
      let!(:location_barcode) { location1.barcode }

      before do
        location1.destroy!
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

    context 'where the labware exists but has no audits' do
      # let!(:labware_barcode) { labware.barcode }
      let(:labware_without_audits) { create(:labware_with_location) }
      let(:audit) { create(:audit_of_labware, labware: labware_without_audits) }
      let(:attributes) { { labware: labware_without_audits, audit: audit } }
      let(:event) { Event.new(attributes) }

      let(:expected_subject) do
        {
          role_type: 'labware',
          subject_type: 'labware',
          friendly_name: labware_without_audits.barcode,
          uuid: labware_without_audits.uuid
        }
      end

      let(:expected_nomethod_message) do
        "Error in Event#for_old_audit?: labware barcode=#{labware_without_audits&.barcode}, " \
          "audit id=#{audit&.id.inspect}. Original error: undefined method 'id' for nil"
      end

      before do
        # Remove all audits from the labware
        labware_without_audits.audits.destroy_all
      end

      it 'throws a NoMethodError when trying to access the last audit' do
        expect { event.for_old_audit? }.to raise_error(NoMethodError, expected_nomethod_message)
      end
    end
  end

  # FAILURE STATES

  context 'where required data is missing' do
    context 'where the location info is missing completely' do
      it 'fails validation' do
        audit.record_data.delete('location')
        expect(event).to_not be_valid
        expect(event.errors.full_messages).to include("The location barcode must be present in 'record_data'")
      end
    end

    context 'where the labware info is missing completely' do
      let(:attributes) { { audit: audit } }

      it 'fails validation' do
        audit.record_data.delete('barcode')
        expect(event).to_not be_valid
        expect(event.errors.full_messages)
          .to include("Either the labware attribute, or a labware barcode in 'record_data' must be present")
      end
    end

    context 'where the audit is missing' do
      let(:attributes) { { labware: labware } }

      it 'fails validation' do
        expect(event).to_not be_valid
        expect(event.errors.full_messages).to include("Audit can't be blank")
      end
    end

    context 'where the audit type is not labware' do
      let(:audit) { create(:audit) }
      let(:attributes) { { audit: audit } }

      it 'fails validation' do
        expect(event).to_not be_valid
        expect(event.errors.full_messages)
          .to include('Events can only be created for Audits where the auditable type is Labware')
      end
    end
  end
end
