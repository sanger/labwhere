require "test_helper"

class LoadDataTest < ActiveSupport::TestCase

  def setup
  end

  test "should load all of the top location data" do
    data = LoadData.new("top_locations")
    data.load!
    assert_operator data.file.length, :>, 0 
    assert_operator CgapTopLocation.all.count, :>, 0
    assert_equal data.file.length, CgapTopLocation.all.count
    assert_equal 1000002, CgapTopLocation.minimum(:id)
    assert_equal 1000143, CgapTopLocation.maximum(:id)

    top_location = CgapTopLocation.find_by(id: 1000004)
    assert_equal "2000000000039", top_location.barcode
    assert_equal "-80 freezer MDFU55V", top_location.name

    top_location = CgapTopLocation.find_by(id: 1000033)
    assert_equal "2000000000329", top_location.barcode
    assert_equal "Air Jacket CO2 Incubator Panasonic MCO-19AIC(UV)-PE", top_location.name

    top_location = CgapTopLocation.find_by(id: 1000103)
    assert_equal "2000000001029", top_location.barcode
    assert_equal "Underbench fridge Liebherr", top_location.name

  end

  test "should load all of the sub location data" do 
    data = LoadData.new("sub_locations")
    data.load!
    assert_operator data.file.length, :>, 0 
    assert_operator CgapSubLocation.all.count, :>, 0
    assert_equal data.file.length, CgapSubLocation.all.count
    assert_equal 2, CgapSubLocation.minimum(:id)
    assert_equal 217228, CgapSubLocation.maximum(:id)

    sub_location = CgapSubLocation.find_by(id: 10)
    assert_equal "Shelf 1", sub_location.name
    assert_equal 1000011, sub_location.cgap_top_location_id
    assert_equal 0, sub_location.rows
    assert_equal 0, sub_location.columns

    sub_location = CgapSubLocation.find_by(id: 217066)
    assert_equal "Stack 1", sub_location.name 
    assert_equal 1000143, sub_location.cgap_top_location_id
    assert_equal 17, sub_location.rows
    assert_equal 1, sub_location.columns

    sub_location = CgapSubLocation.find_by(id: 2723)
    assert_equal "Box A", sub_location.name
    assert_equal 2722, sub_location.cgap_top_location_id
    assert_equal 10, sub_location.rows
    assert_equal 10, sub_location.columns

  end

  test "should load all of the labware data" do
    data = LoadData.new("labwares")
    data.load!
    assert_operator data.file.length, :>, 0 
    assert_operator CgapLabware.all.count, :>, 0
    assert_equal data.file.length, CgapLabware.all.count
    assert_equal "2000000105185", CgapLabware.minimum(:barcode)
    assert_equal "SAMEA3451112", CgapLabware.maximum(:barcode)

    labware = CgapLabware.find_by(barcode: "2000001872710")
    assert_equal 11, labware.cgap_sub_location_id
    assert_equal 0, labware.row
    assert_equal 0, labware.column

    labware = CgapLabware.find_by(barcode: "2000001036907")
    assert_equal 1169, labware.cgap_sub_location_id
    assert_equal 4, labware.row
    assert_equal 10, labware.column

    labware = CgapLabware.find_by(barcode: "2000002119289")
    assert_equal 1087, labware.cgap_sub_location_id
    assert_equal 7, labware.row
    assert_equal 2, labware.column
  end

  def teardown
    CgapTopLocation.delete_all
    CgapSubLocation.delete_all
    CgapLabware.delete_all
  end

end