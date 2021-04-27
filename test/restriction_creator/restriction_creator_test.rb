# frozen_string_literal: true

require "test_helper"
require "#{Rails.root}/app/lib/restriction_creator/restriction_creator.rb"

class RestrictionCreatorTest < ActiveSupport::TestCase
  attr_reader :site, :building, :room, :delivered, :tray, :fridge, :bin, :site_parent, :building_parent, :room_parent

  def setup
    @site = create(:location_type, name: "Site")
    @building = create(:location_type, name: "Building")
    @room = create(:location_type, name: "Room")
    @delivered = create(:location_type, name: "Delivered")
    @tray = create(:location_type, name: "Tray")
    @bin = create(:location_type, name: "Bin")
    @fridge = create(:location_type, name: "Fridge")
    @site_parent = create(:location, location_type: site)
    @building_parent = create(:location, location_type: building)
    @room_parent = create(:location, location_type: room)
    yaml = YAML::load_file(File.join(Rails.root, "app/data/restrictions.yaml"))
    RestrictionCreator.new(yaml).run!
  end

  test "Empty parent restriction should ensure location has no parent" do
    site.reload
    assert build(:location, name: "Site1", location_type: site).valid?
    refute build(:location, name: "Site2", location_type: site, parent: create(:location)).valid?
  end

  test "uniqueness restriction should ensure location can only have a single occurrence of a name" do
    create(:location, name: "A building", location_type: building)
    refute build(:location, name: "A building", location_type: building).valid?
  end

  test "White list parent restriction should ensure location has a parent of a type indicated in a white list" do
    building.reload
    assert build(:location, name: "Building1", location_type: building, parent: site_parent).valid?
    refute build(:location, name: "Building2", location_type: building, parent: room_parent).valid?
  end

  test "Black list parent restriction should ensure location does not have a parent of a type indicated in a black list" do
    refute build(:location, name: "Fridge1", location_type: fridge, parent: site_parent).valid?
    refute build(:location, name: "Fridge1", location_type: fridge, parent: building_parent).valid?
    assert build(:location, name: "Fridge2", location_type: fridge, parent: room_parent).valid?
  end

  test "should have correct restrictions for locations of types tray, bin, delivered" do
    refute build(:location, name: "Tray1", location_type: tray, parent: site_parent).valid?
    assert build(:location, name: "Tray2", location_type: tray, parent: building_parent).valid?
    refute build(:location, name: "Bin1", location_type: bin, parent: site_parent).valid?
    assert build(:location, name: "Bin2", location_type: bin, parent: building_parent).valid?
    assert build(:location, name: "Delivered1", location_type: delivered, parent: site_parent).valid?
    assert build(:location, name: "Delivered2", location_type: delivered, parent: building_parent).valid?
    # delivered can now have any parent, updated from only allowed building parent
  end

  test "should create the right restrictions from a yaml file" do
    Restriction.delete_all
    LocationType.delete_all
    yaml = YAML::load_file(File.join(Rails.root, "test/fixtures/restrictions_short.yaml"))
    RestrictionCreator.new(yaml).run!
    assert_equal yaml.count, Restriction.all.count
    assert_equal 43, LocationTypesRestriction.all.count
    assert_equal 5, LocationType.all.count
  end
end
