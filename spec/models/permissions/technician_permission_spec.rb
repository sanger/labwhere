# frozen_string_literal: true

require "rails_helper"

RSpec.describe Permissions::TechnicianPermission, type: :model do
  let!(:scientist) { create(:scientist) }
  let!(:administrator) { create(:administrator) }
  let(:permissions) { Permissions.permission_for(build(:technician)) }

  it "should allow access to create a scan" do
    expect(permissions).to allow_permission(:scans, :create)
  end

  it "should allow access to move a location" do
    expect(permissions).to allow_permission(:move_locations, :create)
  end

  it "should be allowed to move a protected location" do
    protected_location = create(:location, protected: true)
    move_location_form = MoveLocationForm.new
    allow(move_location_form).to receive(:child_locations).and_return([protected_location])

    expect(permissions).to allow_permission(:move_locations, :create, move_location_form)
  end

  it "should allow access to empty a location" do
    expect(permissions).to allow_permission(:empty_locations, :create)
  end

  it "should allow access to create a scan through the api" do
    expect(permissions).to allow_permission("api/scans", :create)
  end

  it "should allow access to update a coordinate" do
    expect(permissions).to allow_permission("api/locations/coordinates", :update)
  end

  it "should allow access to bulk update coordinates" do
    expect(permissions).to allow_permission("api/coordinates", :update)
  end

  it "should be allowed to edit an unprotected location" do
    unprotected_location = create(:location, protected: false)
    action = "update"
    location_form = LocationForm.new(unprotected_location)
    allow(location_form).to receive(:action).and_return(action)

    expect(permissions).to allow_permission(:locations, :update, location_form)
  end

  it "should not be allowed to make an unprotected location protected" do
    unprotected_location = create(:location, protected: false)
    action = "update"
    location_form = LocationForm.new(unprotected_location)
    location_form.location.protected = true
    allow(location_form).to receive(:action).and_return(action)

    expect(permissions).to_not allow_permission(:locations, :update, location_form)
  end

  it "should not be allowed to make a protected location unprotected" do
    protected_location = create(:location, protected: true)
    action = "update"
    location_form = LocationForm.new(protected_location)
    location_form.location.protected = false
    allow(location_form).to receive(:action).and_return(action)

    expect(permissions).to_not allow_permission(:locations, :update, location_form)
  end

  it "should be allowed to create a unprotected location" do
    action = "create"
    location_form = LocationForm.new
    location_form.location.protected = false
    allow(location_form).to receive(:action).and_return(action)

    expect(permissions).to allow_permission(:locations, :create, location_form)
  end

  it "should not be allowed to create a protected location" do
    action = "create"
    location_form = LocationForm.new
    location_form.location.protected = true
    allow(location_form).to receive(:action).and_return(action)

    expect(permissions).to_not allow_permission(:locations, :create, location_form)
  end

  it "should be allowed to edit a non-admin user" do
    user_form = UserForm.new(scientist)

    expect(permissions).to allow_permission(:users, :update, user_form)
  end

  it "should not be allowed to make a non-admin user an admin" do
    user_form = UserForm.new(scientist)
    user_form.user.type = "Administrator"

    expect(permissions).to_not allow_permission(:users, :update, user_form)
  end

  it "should not be allowed to edit an admin user" do
    user_form = UserForm.new(administrator)

    expect(permissions).to_not allow_permission(:users, :update, user_form)
  end

  it "should be allowed to create a non-admin user" do
    user_form = UserForm.new
    user_form.user.type = "Scientist"
    expect(permissions).to allow_permission(:users, :create, user_form)
  end

  it "should not be allowed to create an admin user" do
    user_form = UserForm.new
    user_form.user.type = "Administrator"

    expect(permissions).to_not allow_permission(:users, :create, user_form)
  end

  it "should allow access to create or modify a location type" do
    expect(permissions).to allow_permission(:location_types, :create)
    expect(permissions).to allow_permission(:location_types, :update)
  end

  it "should allow access to create or modify a team" do
    expect(permissions).to allow_permission(:teams, :create)
    expect(permissions).to allow_permission(:teams, :update)
  end

  it "should allow access to upload a labware file" do
    expect(permissions).to allow_permission(:upload_labware, :create)
  end
end
