# frozen_string_literal: true

require "rails_helper"

RSpec.describe LocationForm, type: :model do
  let(:params) { attributes_for(:location) }
  let(:controller_params) { { controller: "location", action: "create" } }
  let!(:administrator) { create(:administrator) }

  it "is not valid without an user" do
    location_form = LocationForm.new
    res = location_form.submit(controller_params.merge(location: params))
    expect(res).to be_falsey
    expect(location_form).to_not be_valid
  end

  it "is not valid unless the location is valid" do
    location_form = LocationForm.new
    res = location_form.submit(
      controller_params.merge(location: params.except(:name).merge(user_code: administrator.barcode))
    )
    expect(res).to be_falsey
    expect(location_form).to_not be_valid
  end

  it "is valid creates a new location" do
    location_form = LocationForm.new
    res = location_form.submit(
      controller_params.merge(location: params.merge(user_code: administrator.barcode))
    )
    expect(res).to be_truthy
    expect(location_form).to be_valid
    expect(location_form.location).to be_persisted
  end

  it "can be edited if exists" do
    location = create(:location)
    location_form = LocationForm.new(location)
    new_location = build(:location)
    res = location_form.update(
      controller_params.merge(location: { name: new_location.name }
                                          .merge(user_code: administrator.barcode),
                              action: "update")
    )
    expect(res).to be_truthy
    expect(location.name).to eq(new_location.name)
  end

  it "can be destroyed if it has not been used" do
    controller_params = { controller: "location", action: "create" }
    params = ActionController::Parameters.new(controller_params)
    location = create(:location, name: 'Test Location')
    location_form = LocationForm.new(location)
    res = location_form.destroy(params.merge(user_code: administrator.barcode))
    expect(res).to be_truthy
  end

  it "should create the correct type of location dependent on the attributes" do
    location_form = LocationForm.new
    res = location_form.submit(
      controller_params.merge(location: attributes_for(:unordered_location)
                                          .merge(user_code: administrator.barcode))
    )
    expect(res).to be_truthy
    expect(location_form.location).to be_unordered
    expect(location_form.location.coordinates).to be_empty

    location_form = LocationForm.new
    res = location_form.submit(
      controller_params.merge(location: attributes_for(:ordered_location)
                                          .merge(user_code: administrator.barcode))
    )
    expect(res).to be_truthy
    expect(location_form.location).to be_ordered
    expect(location_form.location.coordinates.count).to eq(create(:ordered_location).coordinates.count)
  end

  describe "multiple locations creation" do
    it "should create multiple locations if start and end are not empty" do
      location_form = LocationForm.new
      res = location_form.submit(
        controller_params.merge(location: params.merge(start_from: "1",
                                                       end_to: "4",
                                                       user_code: administrator.barcode))
      )
      expect(res).to be_truthy
      expect(location_form).to be_valid
    end

    it "should not create multiple locations if start is greater than end" do
      location_form = LocationForm.new
      res = location_form.submit(
        controller_params.merge(location: params.merge(start_from: "2",
                                                       end_to: "1",
                                                       user_code: administrator.barcode))
      )
      expect(res).to be_falsey
      expect(location_form).to_not be_valid
    end

    it "should not create multiple locations if start and end are equal" do
      location_form = LocationForm.new
      res = location_form.submit(
        controller_params.merge(location: params.merge(start_from: "1",
                                                       end_to: "1",
                                                       user_code: administrator.barcode))
      )
      expect(res).to be_falsey
      expect(location_form).to_not be_valid
    end

    it "should not create multiple locations if at least one with the same name exists within the same location" do
      location_form = LocationForm.new
      parent_location = create(:unordered_location)
      child_location = create(:location, parent: parent_location, name: "Test Location 2")
      res = location_form.submit(
        controller_params.merge(location: params.merge(
          name: "Test Location",
          start_from: "1",
          end_to: "3",
          parent: parent_location,
          user_code: administrator.barcode
        ))
      )
      expect(res).to be_falsey
      expect(location_form).to_not be_valid
      expect(location_form.location).to_not be_persisted
      expect(child_location).to be_persisted
      expect(child_location.parent).to eq(parent_location)
      location = Location.find(parent_location.id)
      expect(location.children.count).to eq(1)
    end
  end
end
