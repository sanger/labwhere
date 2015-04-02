#As a SM Manager (Admin) I want to create new locations to enable RAS's to track labware whereabouts

require 'test_helper'

class LocationTypeTest < ActionDispatch::IntegrationTest

  attr_reader :location_type_count

  def setup
    @location_type_count = LocationType.count
  end

  test "should be able to create a new type" do
    visit new_location_type_path
    fill_in "Name", with: "Incubator 37C"
    click_button "Create Location type"
    assert page.has_content? "Location type successfully created"
    assert location_type_count+1, LocationType.count
  end

  def teardown
  end
  
end