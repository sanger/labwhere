require "test_helper"

class MigrateTopLocationsTest < ActiveSupport::TestCase

  def setup
    LoadData.new("top_locations").load!
    MigrateTopLocations.run!
  end

  test "should migrate all of the top locations data" do
    assert_operator Location.all.count, :>, 0
    assert_equal Location.all.count, CgapTopLocation.all.count
  end

  test "should add the correct location types" do
    assert_equal LocationType.find_by(name: "Freezer -80C"), Location.find_by(name: "-80 freezer (dual compressor) MDFU500VX-PE").location_type
    assert_equal LocationType.find_by(name: "Nitrogen Freezer"), Location.find_by(name: "CryoStore Labs 40K").location_type
    assert_equal LocationType.find_by(name: "Automatic Incubator"), Location.find_by(name: "Cytomatic incubator").location_type
  end

  test "should provide a link between the CGAP and Labwhere data" do
    assert_equal CgapTopLocations.first.name, Location.find(CgapTopLocations.first.labwhere_id).name
    assert_equal CgapTopLocations.last.name, Location.find(CgapTopLocations.last.labwhere_id).name
  end

  def teardown
    CgapTopLocation.delete_all
  end
end
