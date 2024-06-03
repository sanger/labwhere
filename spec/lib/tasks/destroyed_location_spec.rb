# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'destroyed_location:create' do
  before do
    Rails.application.load_tasks
  end

  it 'creates the Destroyed LocationType and Location' do
    Rake::Task['destroyed_location:create'].invoke

    location_type = LocationType.find_by(name: 'Destroyed')
    expect(location_type).not_to be_nil

    location = UnorderedLocation.find_by(name: 'Destroyed')
    expect(location).not_to be_nil
    expect(location.barcode).to eq('lw-destroyed')
    expect(location.location_type).to eq(location_type)
    expect(location.parent.name).to eq('Sanger')
  end
end
