require "test_helper"

class MigrateLocationsTest < ActiveSupport::TestCase
  def setup
    Cgap::MigrateTopLevelLocations.run!("test/fixtures")
    Cgap::MigrateLocations.run!("test/fixtures")
  end

  test "should migrate all of the locations data" do
    assert_operator Location.all.count, :>, 0
    assert_equal Cgap::Location.all.count + Cgap::Storage.pluck(:top_location).uniq.length, Location.all.count - 2
  end

  test "should add the correct location types" do
    assert_equal LocationType.find_by(name: "Shelf"), Location.where("name LIKE 'Shelf%'").first.location_type
    assert_equal LocationType.find_by(name: "Stack"), Location.where("name LIKE 'Stack%'").first.location_type
    assert_equal LocationType.find_by(name: "Freezer -80C"), Location.find_by(name: "-80 freezer (dual compressor) MDFU500VX-PE").location_type
    assert_equal LocationType.find_by(name: "Nitrogen Freezer"), Location.find_by(name: "CryoStore Labs 40K").location_type
    assert_equal LocationType.find_by(name: "Automatic Incubator"), Location.find_by(name: "Cytomatic incubator").location_type
  end

  test "should provide a link between the CGAP and Labwhere data" do
    assert_equal Cgap::Location.first.name, Location.find(Cgap::Location.first.labwhere_id).name
    assert_equal Cgap::Location.last.name, Location.find(Cgap::Location.last.labwhere_id).name
  end

  test "should add the correct top level parent" do
    cgap_locations = Cgap::Location.where.not(barcode: nil)
    assert_equal Location.find(Cgap::Storage.find_by(barcode: cgap_locations.first.barcode).labwhere_id), Location.find(cgap_locations.first.labwhere_id).parent
    assert_equal Location.find(Cgap::Storage.find_by(barcode: cgap_locations.last.barcode).labwhere_id), Location.find(cgap_locations.last.labwhere_id).parent
  end

  test "should add the parent location" do
    cgap_locations = Cgap::Location.where.not(parent_id: nil)
    cgap_location = cgap_locations.first
    location = Location.find(cgap_location.labwhere_id)
    assert_equal Location.find(cgap_location.parent.labwhere_id), location.parent

    cgap_location = cgap_locations.last
    location = Location.find(cgap_location.labwhere_id)
    assert_equal Location.find(cgap_location.parent.labwhere_id), location.parent
  end

  test "should add coordinates to ordered locations" do
    ordered_locations = Cgap::Location.where("rows > 0 and columns > 0")

    cgap_location = ordered_locations.first
    location = Location.find(cgap_location.labwhere_id)
    assert location.ordered?
    assert_equal cgap_location.rows * cgap_location.columns, location.coordinates.count

    cgap_location = ordered_locations.last
    location = Location.find(cgap_location.labwhere_id)
    assert location.ordered?
    assert_equal cgap_location.rows * cgap_location.columns, location.coordinates.count
  end

  def teardown
    Cgap::Storage.delete_all
    Cgap::Location.delete_all
  end
end
