# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Labware, type: :model do
  it 'has a uuid after creation' do
    expect(create(:labware).uuid).to be_present
  end

  it "is invalid without a barcode" do
    expect(build(:labware, barcode: nil)).to_not be_valid
  end

  it "is invalid without a unique barcode" do
    labware = create(:labware)
    expect(build(:labware, barcode: labware.barcode)).to_not be_valid
  end

  it "can only be added to a location that is nested" do
    expect(build(:labware, location: build(:location))).to_not be_valid
    expect(build(:labware, location: build(:location_with_parent))).to be_valid
  end

  it "can be added to a location that is unknown" do
    expect(build(:labware, location: UnknownLocation.get)).to be_valid
  end

  it "exists" do
    expect(create(:labware).exists).to eq("Yes")
  end

  it "is destroyed it will be soft deleted with all associations removed" do
    labware = create(:labware, location: create(:location_with_parent))
    labware.destroy
    expect(Labware.deleted.count).to eq(1)
    expect(labware.reload.location).to be_empty
  end

  it "is created with no location should set location to be empty" do
    labware = create(:labware)
    expect(labware.location).to be_empty
  end

  it "#find_by_code should find labware by barcode" do
    labware = create(:labware)
    expect(Labware.find_by_code(labware.barcode)).to eq(labware)
  end

  it "#by_barcode should return a list of labwares for the barcodes" do
    create_list(:labware, 5)
    expect(Labware.by_barcode(Labware.pluck(:barcode)).count).to eq(5)
  end

  it "#location should always be returned whether labware is attached to a location, coordinate or nothing" do
    location = create(:location_with_parent)
    coordinate = create(:coordinate)
    labware_1 = create(:labware, location: location)
    expect(labware_1.location).to eq(location)
    labware_2 = create(:labware, coordinate: coordinate)
    expect(labware_2.location).to eq(coordinate.location)
    labware_3 = create(:labware)
    expect(labware_3.location).to be_empty
  end

  it "#as_json should have the correct attributes" do
    labware = create(:labware)
    json = labware.as_json
    expect(json["created_at"]).to eq(labware.created_at.to_s(:uk))
    expect(json["updated_at"]).to eq(labware.updated_at.to_s(:uk))
    expect(json["location"]).to eq(labware.location.barcode)
    expect(json["location_id"]).to be_nil
    expect(json["coordinate_id"]).to be_nil
    expect(json["deleted_at"]).to be_nil
    expect(json["previous_location_id"]).to be_nil
  end

  it "#flush_coordinate should remove coordinate" do
    coordinate = create(:coordinate)
    labware = create(:labware)
    coordinate.fill(labware)
    labware.flush_coordinate
    labware.save
    expect(labware.coordinate).to be_vacant
    expect(coordinate.reload).to be_vacant
  end

  it "#flush_location should remove location" do
    labware = create(:labware, location: create(:location_with_parent))
    labware.flush_location
    labware.save
    expect(labware.location).to be_empty
  end

  it "#flush should remove location and coordinate" do
    labware = create(:labware, location: create(:location_with_parent), coordinate: create(:coordinate))
    labware.flush
    labware.save
    expect(labware.location).to be_empty
    expect(labware.coordinate).to be_vacant
  end

  it "#find_or_initialize_by_barcode should create or find a labware" do
    labware = create(:labware)
    expect(Labware.find_or_initialize_by_barcode(labware.barcode)).to eq(labware)
    expect(Labware.find_or_initialize_by_barcode(barcode: labware.barcode)).to eq(labware)
    expect(Labware.find_or_initialize_by_barcode("999")).to be_new_record
  end

  it 'should have a full path string' do
    location_1 = create(:location, name: 'Location_1')
    location_2 = create(:location, name: 'Location_2', parent: location_1)
    location_3 = create(:location, name: 'Location_3', parent: location_2)

    expect(create(:labware, location: location_3).full_path).to eq('Location_1 > Location_2 > Location_3')
  end

  describe '#write_event' do
    it 'publishes a message' do
      labware = create(:labware)
      audit = create(:audit)

      expect(Messages).to receive(:publish)
      labware.write_event(audit)
    end
  end

  describe 'audit records' do
    let(:administrator) { create(:administrator) }

    it 'when a labware has already been created but is scanned into the same location' do
      labware = create(:labware_with_location)
      labware.create_audit(administrator)
      expect(labware.audits.count).to eq(1)
      expect(labware.audits.first.action).to eq(Audit::CREATE_ACTION)

      location = labware.location
      labware.update(location: location)
      labware.create_audit(administrator)

      expect(labware.audits.count).to eq(2)
      expect(labware.audits.last.action).to eq(Audit::UPDATE_ACTION)
    end
  end
end
