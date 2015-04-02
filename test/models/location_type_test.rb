require 'test_helper'

class LocationTypeTest < ActiveSupport::TestCase

  test "should build a valid record" do
    assert build(:location_type).valid?
  end

  test "should have a name" do
    refute build(:location_type, name: nil).valid?
  end

  test "should have a unique name" do
    create(:location_type, name: "Unique Name")
    refute build(:location_type, name: "Unique Name").valid?
  end

  test "name should not be case sensitive" do
    create(:location_type, name: "Unique Name")
    refute build(:location_type, name: "unique name").valid?
  end

end
