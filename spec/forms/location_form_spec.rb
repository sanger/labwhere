require "rails_helper"

RSpec.describe LocationTypeForm, type: :model do 

  let(:controller_params)           { { controller: "location", action: "create"} }
  let(:params)                      { ActionController::Parameters.new(controller_params) }
  let!(:administrator)              { create(:administrator) }
  let(:location_params)             { attributes_for(:location).merge(user_code: administrator.barcode)}
  let(:unordered_location_params)   { attributes_for(:unordered_location).merge(user_code: administrator.barcode)}
  let(:ordered_location_params)     { attributes_for(:ordered_location).merge(user_code: administrator.barcode)}
  let!(:parent_locations)           { create_list(:location, 2)}

  it "should be able to add a parent location using a barcode" do
    location_form = LocationForm.new
    expect(location_form.submit(params.merge(location: location_params.merge(parent_id: parent_locations.first.id)))).to be_truthy
    expect(location_form.parent).to eq(parent_locations.first)
  end

  # it "should return an error if the parent barcode does not represent a valid location" do
  #   location_form = LocationForm.new
  #   expect(location_form.submit(params.merge(location: location_params.merge(parent_barcode: "666666:1")))).to be_falsey
  #   expect(location_form.errors.full_messages).to include("Parent #{I18n.t("errors.messages.existence")}")
  # end
  #
  # it "parent_barcode should take precedence over parent_id" do
  #   location_form = LocationForm.new
  #   expect(location_form.submit(params.merge(
  #     location: location_params.merge(parent_barcode: parent_locations.first.barcode, parent_id: parent_locations.last.id)))).to be_truthy
  #   expect(location_form.parent).to eq(parent_locations.first)
  # end

  it "should create the correct type of location dependent on the attributes" do
    location_form = LocationForm.new
    location_form.submit(params.merge(location: unordered_location_params))
    expect(location_form.location).to be_unordered
    expect(location_form.location.coordinates).to be_empty

    location_form = LocationForm.new
    location_form.submit(params.merge(location: ordered_location_params))
    expect(location_form.location).to be_ordered
    expect(location_form.location.coordinates.count).to eq(create(:ordered_location).coordinates.count)
  end

end