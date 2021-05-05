# frozen_string_literal: true

require "rails_helper"

RSpec.describe Permissions::GuestPermission, type: :model do
  let(:permissions) { Permissions.permission_for(build(:guest)) }

  it "should not allow anything" do
    expect(permissions).to_not allow_permission(:any, :thing)
  end

  it "should not allow access to create a scan" do
    expect(permissions).to_not allow_permission(:scans, :create)
  end

  it "should not allow access to empty a location" do
    expect(permissions).to_not allow_permission(:empty_locations, :create)
  end

  it "should not allow access to create a scan through the api" do
    expect(permissions).to_not allow_permission("api/scans", :create)
  end

  it "should not allow access to update a coordinate" do
    expect(permissions).to_not allow_permission("api/locations/coordinates", :update)
  end

  it "should not allow access to bulk update coordinates" do
    expect(permissions).to_not allow_permission("api/coordinates", :update)
  end

  it "should not allow access to upload a labware file" do
    expect(permissions).to_not allow_permission(:upload_labware, :create)
  end

  it "should not allow access to create or modify a location" do
    expect(permissions).to_not allow_permission(:locations, :create)
    expect(permissions).to_not allow_permission(:locations, :update)
  end

  it "should not allow access to create or modify a location type" do
    expect(permissions).to_not allow_permission(:location_types, :create)
    expect(permissions).to_not allow_permission(:location_types, :update)
  end

  it "should not allow access to create or modify a user" do
    expect(permissions).to_not allow_permission(:users, :create)
    expect(permissions).to_not allow_permission(:users, :update)
  end

  it "should not allow access to create or modify a team" do
    expect(permissions).to_not allow_permission(:teams, :create)
    expect(permissions).to_not allow_permission(:teams, :update)
  end
end
