require "test_helper"

class LoadDataTest < ActiveSupport::TestCase

  def setup
  end

  test "should load all of the top location data" do
    data = Cgap::LoadData.new("locations_top", "test/fixtures")
    data.load!
    assert_operator data.file.length, :>, 0 
    assert_operator Cgap::Location.all.count, :>, 0
    assert_equal data.file.length, Cgap::Location.all.count
    assert_equal 1000002, Cgap::Location.minimum(:id)
    assert_equal 1000143, Cgap::Location.maximum(:id)

    location = Cgap::Location.find_by(id: 1000004)
    assert_equal "2000000000039", location.barcode
    assert_equal "-80 freezer MDFU55V", location.name

    location = Cgap::Location.find_by(id: 1000033)
    assert_equal "2000000000329", location.barcode
    assert_equal "Air Jacket CO2 Incubator Panasonic MCO-19AIC(UV)-PE", location.name

    location = Cgap::Location.find_by(id: 1000103)
    assert_equal "2000000001029", location.barcode
    assert_equal "Underbench fridge Liebherr", location.name

  end

  test "should load all of the sub location data" do 
    data = Cgap::LoadData.new("locations_sub", "test/fixtures")
    data.load!
    assert_operator data.file.length, :>, 0 
    assert_operator Cgap::Location.all.count, :>, 0
    assert_equal data.file.length, Cgap::Location.all.count
    assert_equal 2, Cgap::Location.minimum(:id)
    assert_equal 217066, Cgap::Location.maximum(:id)

    location = Cgap::Location.find_by(id: 181)
    assert_equal "Shelf 1", location.name
    assert_equal 1000056, location.parent_id
    assert_equal 0, location.rows
    assert_equal 0, location.columns

    location = Cgap::Location.find_by(id: 217066)
    assert_equal "Stack 1", location.name 
    assert_equal 1000143, location.parent_id
    assert_equal 17, location.rows
    assert_equal 1, location.columns

    location = Cgap::Location.find_by(id: 185)
    assert_equal "Box A", location.name
    assert_equal 184, location.parent_id
    assert_equal 10, location.rows
    assert_equal 10, location.columns

  end

  test "should load all of the labware data" do
    data = Cgap::LoadData.new("labwares", "test/fixtures")
    data.load!
    assert_operator data.file.length, :>, 0 
    assert_operator Cgap::Labware.all.count, :>, 0
    assert_equal data.file.length, Cgap::Labware.all.count
    assert_equal "2000000124506", Cgap::Labware.minimum(:barcode)
    assert_equal "SAMEA3450862", Cgap::Labware.maximum(:barcode)

    labware = Cgap::Labware.find_by(barcode: "2000001279441")
    assert_equal 3850, labware.cgap_location_id
    assert_equal 0, labware.row
    assert_equal 0, labware.column

    labware = Cgap::Labware.find_by(barcode: "2000002372202")
    assert_equal 1945, labware.cgap_location_id
    assert_equal 2, labware.row
    assert_equal 7, labware.column

    labware = Cgap::Labware.find_by(barcode: "SAMEA3450817")
    assert_equal 1941, labware.cgap_location_id
    assert_equal 2, labware.row
    assert_equal 8, labware.column
  end

  test "should load all of the parent location data" do
    data = Cgap::LoadData.new("storage_equipment", "test/fixtures", "\r")
    data.load!
    assert_operator data.file.length, :>, 0
    assert_operator Cgap::Storage.all.count, :>, 0
    assert_equal data.file.length, Cgap::Storage.all.count
  end

  def teardown
    Cgap::Storage.delete_all
    Cgap::Location.delete_all
    Cgap::Labware.delete_all
  end

end