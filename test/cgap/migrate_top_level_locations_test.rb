require "test_helper"

class MigrateTopLevelLocationsTest < ActiveSupport::TestCase

  def setup
    MigrateTopLevelLocations.run!("test/fixtures")
  end

  test "should create site and building" do
    refute_nil Location.find_by(name: "Sanger")
    refute_nil Location.find_by(name: "Sulston")
  end

  test "should migrate all of the storage equipment data" do
    assert_operator Location.all.count, :>, 0
    assert_equal CgapStorage.pluck(:top_location).uniq.length, Location.all.count-2
  end

  test "should assign the correct location type" do
    assert_equal LocationType.find_by(name: "Room"), Location.find(CgapStorage.first.labwhere_id).location_type
    assert_equal LocationType.find_by(name: "Room"), Location.find(CgapStorage.last.labwhere_id).location_type
  end

  test "should assign the correct parent" do

    assert_equal Location.find_by(name: "Sanger"), Location.find_by(name: "Sulston").parent

    assert_equal Location.find(CgapStorage.first.labwhere_id).parent, Location.find_by(name: "Sulston")
    assert_equal Location.find(CgapStorage.last.labwhere_id).parent, Location.find_by(name: "Sulston")
  end

  test "should provide a link between the CGAP and Labwhere data" do
    assert_equal CgapStorage.first.top_location, Location.find(CgapStorage.first.labwhere_id).name
    assert_equal CgapStorage.last.top_location, Location.find(CgapStorage.last.labwhere_id).name
  end

  def teardown
  end
  
end