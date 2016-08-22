require "test_helper"

Dir[File.join(Rails.root,"lib","restriction_creator","*.rb")].each { |f| require f }

class RestrictionCreatorTest < ActiveSupport::TestCase

  attr_reader :site, :building, :room, :delivered, :tray

  def setup
    @site = create(:location_type, name: "Site")
    @building = create(:location_type, name: "Building")
    @room = create(:location_type, name: "Room")
    @delivered = create(:location_type, name: "Delivered")
    @tray = create(:location_type, name: "Tray")
    @fridge = create(:location_type, name: "Fridge")
  end

  test "Empty parent restriction should ensure location has no parent" do
    RestrictionCreator.new({"1" => {"validator" => "EmptyParentValidator", "location_type" => site.name}}).run!
    assert build(:location, name: "Site", location_type: site).valid?
    refute build(:location, name: "Site", location_type: site, parent: create(:location)).valid?
  end

  test "uniqueness restriction should ensure location can only have a single occurrence of a name" do
    RestrictionCreator.new("1" => {"validator" => "ActiveRecord::Validations::UniquenessValidator",
      "params" => { "attributes" => [:name], "scope" => :location_type_id, "message" => "has already been taken for this Location Type" },
      "location_type" => building.name }).run!
    create(:location, name: "A building", location_type: building)
    refute build(:location, name: "A building", location_type: building).valid?
  end

 
end