require "rails_helper"

RSpec.describe LocationForm, type: :model do
  let(:controller_params)           { { controller: "location", action: "create" } }
  # let(:params)                      { ActionController::Parameters.new(controller_params) }
  let!(:administrator)              { create(:administrator) }
  let(:location_params)             { attributes_for(:location).merge(user_code: administrator.barcode) }
  let(:unordered_location_params)   { attributes_for(:unordered_location).merge(user_code: administrator.barcode) }
  let(:ordered_location_params)     { attributes_for(:ordered_location).merge(user_code: administrator.barcode) }
  let!(:parent_locations)           { create_list(:location, 2) }

  it "should be able to add a parent location using a barcode" do
    location_form = LocationForm.new
    expect(location_form.submit(
             controller_params.merge(location: location_params.merge(parent_id: parent_locations.first.id))
           )).to be_truthy
    expect(location_form.parent).to eq(parent_locations.first)
  end

  it "should create the correct type of location dependent on the attributes" do
    location_form = LocationForm.new
    location_form.submit(controller_params.merge(location: unordered_location_params))
    expect(location_form.location).to be_unordered
    expect(location_form.location.coordinates).to be_empty

    location_form = LocationForm.new
    location_form.submit(controller_params.merge(location: ordered_location_params))
    expect(location_form.location).to be_ordered
    expect(location_form.location.coordinates.count).to eq(create(:ordered_location).coordinates.count)
  end

  it "should only destroy a location if it has not been used" do
    controller_params = { controller: "location", action: "create" }
    location = create(:location, name: 'Test Location')
    location_form = LocationForm.new(location)
    expect(location_form.destroy(controller_params.merge(user_code: administrator.barcode))).to be_truthy
  end
end
