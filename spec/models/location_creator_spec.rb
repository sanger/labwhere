# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationCreator, type: :model do
  let!(:site)             { create(:location_type, name: 'Site') }
  let!(:building)         { create(:location_type, name: 'Building') }
  let!(:location_creator) do
    LocationCreator.new('Site' => { location: 'Sanger' },
                        'Building' => { location: 'Ogilvie' },
                        'Room' => { location: 'AA315' },
                        'Shelf' => { location: 'Shelf' },
                        'Tray' => { location: 'Tray', number: 50 })
  end

  it 'should create the location types only if they exist' do
    location_creator.run!
    expect(LocationType.where(name: 'Site').count).to eq(1)
    expect(LocationType.where(name: 'Building').count).to eq(1)
    expect(LocationType.where(name: 'Room').count).to eq(1)
    expect(LocationType.where(name: 'Shelf').count).to eq(1)
    expect(LocationType.where(name: 'Tray').count).to eq(1)
  end

  it "should only create a location if it doesn't exist" do
    location_creator.run!
    expect(Location.where(name: 'Sanger').count).to eq(1)
    expect(Location.where(name: 'Ogilvie').count).to eq(1)
    expect(Location.where(name: 'AA315').count).to eq(1)
  end

  it 'should create the correct locations' do
    location_creator.run!
    expect(Location.find_by(name: 'Sanger').location_type.name).to eq('Site')
    expect(Location.find_by(name: 'Ogilvie').location_type.name).to eq('Building')
    expect(Location.find_by(name: 'AA315').location_type.name).to eq('Room')
    expect(Location.find_by(name: 'Shelf').location_type.name).to eq('Shelf')
    expect(Location.find_by(name: 'Tray 33').location_type.name).to eq('Tray')
  end

  it 'should create all of the locations' do
    location_creator.run!
    expect(Location.where('name like ?', '%Shelf%').count).to eq(1)
    expect(Location.where('name like ?', '%Tray%').count).to eq(50)
  end

  it 'should create the corresponding parentage' do
    location_creator.run!
    expect(Location.find_by(name: 'Ogilvie').parent.name).to eq('Sanger')
    expect(Location.find_by(name: 'AA315').parent.name).to eq('Ogilvie')
    expect(Location.find_by(name: 'AA315').children.count).to eq(1)
    expect(Location.find_by(name: 'Shelf').children.count).to eq(50)
    expect(Location.find_by(name: 'Shelf').children.last.name).to eq('Tray 50')
    expect(Location.find_by(name: 'Shelf').children.first.name).to eq('Tray 1')
  end
end
