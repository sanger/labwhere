# frozen_string_literal: true

require 'test_helper'

Dir[File.join(Rails.root, 'lib', 'location_creator', '*.rb')].sort.each { |f| require f }

class LocationCreatorTest < ActiveSupport::TestCase
  def setup
    site = LocationType.create(name: 'Site')
    building = LocationType.create(name: 'Building')
    UnorderedLocation.create(name: 'Sanger', location_type: site)
    location_creator = LocationCreator.new('Site' => { location: 'Sanger' },
                                           'Building' => { location: 'Ogilvie' },
                                           'Room' => { location: 'AA315' },
                                           'Shelf' => { location: 'Shelf', number: 2 },
                                           'Tray' => { location: 'Tray', number: 50 })
    location_creator.run!
  end

  test 'should create the location types only if they exist' do
    assert_equal 1, LocationType.where(name: 'Site').count
    assert_equal 1, LocationType.where(name: 'Building').count
    assert_equal 1, LocationType.where(name: 'Room').count
    assert_equal 1, LocationType.where(name: 'Shelf').count
    assert_equal 1, LocationType.where(name: 'Tray').count
  end

  test "should only create a location if it doesn't exist" do
    assert_equal 1, Location.where(name: 'Sanger').count
    assert_equal 1, Location.where(name: 'Ogilvie').count
    assert_equal 1, Location.where(name: 'AA315').count
  end

  test 'should create the correct locations' do
    assert_equal 'Site', Location.find_by(name: 'Sanger').location_type.name
    assert_equal 'Building', Location.find_by(name: 'Ogilvie').location_type.name
    assert_equal 'Room', Location.find_by(name: 'AA315').location_type.name
    assert_equal 'Shelf', Location.find_by(name: 'Shelf 1').location_type.name
    assert_equal 'Tray', Location.find_by(name: 'Tray 33').location_type.name
  end

  test 'should create all of the locations' do
    assert_equal 2, Location.where('name like ?', '%Shelf%').count
    assert_equal 100, Location.where('name like ?', '%Tray%').count
    refute_nil Location.find_by(name: 'Tray 50')
    refute_nil Location.find_by(name: 'Shelf 2')
  end

  test 'should create the corresponding parentage' do
    assert_equal 'Sanger', Location.find_by(name: 'Ogilvie').parent.name
    assert_equal 'Ogilvie', Location.find_by(name: 'AA315').parent.name
    assert_equal 2, Location.find_by(name: 'AA315').children.count
    assert_equal 50, Location.find_by(name: 'Shelf 1').children.count
    assert_equal 50, Location.find_by(name: 'Shelf 2').children.count
    assert_equal 'Tray 50', Location.find_by(name: 'Shelf 1').children.last.name
    assert_equal 'Tray 1', Location.find_by(name: 'Shelf 2').children.first.name
  end

  def teardown; end
end
