# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Labware, type: :model do
  it 'has a uuid after creation' do
    expect(create(:labware).uuid).to be_present
  end

  it 'is invalid without a barcode' do
    expect(build(:labware, barcode: nil)).to_not be_valid
  end

  it 'is invalid without a unique barcode' do
    labware = create(:labware)
    expect(build(:labware, barcode: labware.barcode)).to_not be_valid
  end

  it 'can only be added to a location that is nested' do
    expect(build(:labware, location: build(:location))).to_not be_valid
    expect(build(:labware, location: build(:location_with_parent))).to be_valid
  end

  it 'can be added to a location that is unknown' do
    expect(build(:labware, location: UnknownLocation.get)).to be_valid
  end

  it 'exists' do
    expect(create(:labware).exists).to eq('Yes')
  end

  it 'is destroyed it will be soft deleted with all associations removed' do
    labware = create(:labware, location: create(:location_with_parent))
    labware.destroy
    expect(Labware.deleted.count).to eq(1)
    expect(labware.reload.location).to be_empty
  end

  it 'is created with no location should set location to be empty' do
    labware = create(:labware)
    expect(labware.location).to be_empty
  end

  it '#find_by_barcode should find labware by barcode' do
    labware = create(:labware)
    expect(Labware.find_by_barcode(labware.barcode)).to eq(labware)
  end

  it '#by_barcode should return a list of labwares for the barcodes' do
    create_list(:labware, 5)
    expect(Labware.by_barcode(Labware.pluck(:barcode)).count).to eq(5)
  end

  it "#by_barcode_known_locations should return a list of labwares for the given 'known' location barcodes" do
    labwares = []
    labwares += create_list(:labware, 2)
    labwares += create_list(:labware_with_location, 2)
    labwares += create_list(:labware_with_ordered_location, 2)
    labwares += [create(:labware, location: UnknownLocation.get)]
    expect(Labware.by_barcode_known_locations(labwares.pluck(:barcode)).count).to eq(4)
  end

  it '#by_location_barcode should return a list of labwares for the given location barcodes' do
    labwares = []
    labwares += create_list(:labware, 2)
    labwares += create_list(:labware_with_location, 2)
    labwares += create_list(:labware_with_ordered_location, 2)
    labwares += [create(:labware, location: UnknownLocation.get)]
    location_barcodes = labwares.map { |labware| labware.location.barcode }
    expect(Labware.by_location_barcode(location_barcodes).count).to eq(5)
  end

  it '#location should always be returned whether labware is attached to a location, coordinate or nothing' do
    location = create(:location_with_parent)
    coordinate = create(:coordinate)
    labware1 = create(:labware, location: location)
    expect(labware1.location).to eq(location)
    labware2 = create(:labware, coordinate: coordinate)
    expect(labware2.location).to eq(coordinate.location)
    labware3 = create(:labware)

    expect(labware3.location).to be_empty
  end

  it '#as_json should have the correct attributes' do
    labware = create(:labware)
    json = labware.as_json
    expect(json['created_at']).to eq(labware.created_at.to_fs(:uk))
    expect(json['updated_at']).to eq(labware.updated_at.to_fs(:uk))
    expect(json['location']).to eq(labware.location.barcode)
    expect(json['location_id']).to be_nil
    expect(json['coordinate_id']).to be_nil
    expect(json['deleted_at']).to be_nil
    expect(json['previous_location_id']).to be_nil
  end

  it '#flush_coordinate should remove coordinate' do
    coordinate = create(:coordinate)
    labware = create(:labware)
    coordinate.fill(labware)
    labware.flush_coordinate
    labware.save
    expect(labware.coordinate).to be_vacant
    expect(coordinate.reload).to be_vacant
  end

  it '#flush_location should remove location' do
    labware = create(:labware, location: create(:location_with_parent))
    labware.flush_location
    labware.save
    expect(labware.location).to be_empty
  end

  it '#flush should remove location and coordinate' do
    labware = create(:labware, location: create(:location_with_parent), coordinate: create(:coordinate))
    labware.flush
    labware.save
    expect(labware.location).to be_empty
    expect(labware.coordinate).to be_vacant
  end

  it '#find_or_initialize_by_barcode should create or find a labware' do
    labware = create(:labware)
    expect(Labware.find_or_initialize_by_barcode(labware.barcode)).to eq(labware)
    expect(Labware.find_or_initialize_by_barcode(barcode: labware.barcode)).to eq(labware)
    expect(Labware.find_or_initialize_by_barcode('999')).to be_new_record
  end

  it 'should have a full path string' do
    location1 = create(:location, name: 'Location1')
    location2 = create(:location, name: 'Location2', parent: location1)
    location3 = create(:location, name: 'Location3', parent: location2)

    expect(create(:labware, location: location3).full_path).to eq('Location1 > Location2 > Location3')
  end

  describe '#write_event' do
    it 'publishes a message' do
      labware = create(:labware)
      audit = create(:audit)

      expect(Messages).to receive(:publish)
      labware.write_event(audit)
    end
  end

  describe 'breadcrumbs' do
    it 'when the labware has no location' do
      labware = create(:labware)
      expect(labware.breadcrumbs).to be_nil
    end

    it 'when the labware has an unknown location' do
      location = create(:unknown_location)
      labware = create(:labware, location: location)
      expect(labware.breadcrumbs).to eq(location.parentage)
    end

    it 'when the labware has a location' do
      location = create(:location_with_parent)
      labware = create(:labware, location: location)
      expect(labware.breadcrumbs).to eq(location.parentage)
    end
  end

  describe 'audit records' do
    let(:administrator) { create(:administrator) }

    let(:create_action) { AuditAction.new(AuditAction::CREATE) }
    let(:update_action) { AuditAction.new(AuditAction::UPDATE) }

    it 'when a labware has already been created but is scanned into the same location' do
      labware = create(:labware_with_location)
      labware.create_audit(administrator)
      expect(labware.audits.count).to eq(1)
      expect(labware.audits.first.action).to eq(AuditAction::CREATE)

      location = labware.location
      labware.update(location: location)
      labware.create_audit(administrator)

      expect(labware.audits.count).to eq(2)
      expect(labware.audits.last.action).to eq(AuditAction::UPDATE)
    end

    context 'message' do
      let!(:user) { create(:user) }

      it 'when it is new labware' do
        labware = create(:labware)
        audit = labware.create_audit(user)
        expect(audit.message).to eq(create_action.display_text)
      end

      it 'when it is new labware with a location' do
        labware = create(:labware_with_location)
        audit = labware.create_audit(user)
        expect(audit.message).to eq("#{create_action.display_text} and stored in #{labware.breadcrumbs}")
      end

      it 'when it is existing labware with a location' do
        labware = create(:labware_with_location)
        labware.create_audit(user)
        labware.update(location: create(:location_with_parent))
        audit = labware.create_audit(user)
        expect(audit.message).to eq("#{update_action.display_text} and stored in #{labware.breadcrumbs}")
      end
    end
  end
end
