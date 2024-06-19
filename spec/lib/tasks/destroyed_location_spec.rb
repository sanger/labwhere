# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'destroyed_location:create' do
  before do
    Rails.application.load_tasks
    # The rake task assumes that the parent location with the name 'Sanger' and
    # the location type name 'Site' already exists.
    parent_type = create(:location_type, name: 'Site')
    create(:unordered_location, name: 'Sanger', location_type: parent_type)
  end

  it 'creates the Destroyed LocationType and Location' do
    expect do
      Rake::Task['destroyed_location:create'].invoke
    end.to change { UnorderedLocation.count }.by(1)

    location_type = LocationType.find_by(name: 'Destroyed')
    expect(location_type).not_to be_nil

    location = UnorderedLocation.find_by(name: 'Destroyed')
    expect(location).not_to be_nil
    expect(location.barcode).to eq('lw-destroyed')
    expect(location.location_type).to eq(location_type)
    expect(location.parent.name).to eq('Sanger')
  end
end
