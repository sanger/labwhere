# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmptyLocationForm, type: :model do
  let(:create_empty_location)       { EmptyLocationForm.new }
  let!(:user)                       { create(:scientist) }
  let(:params)                      { ActionController::Parameters.new(controller: "empty_locations", action: "create") }
  let(:location)                    { create(:unordered_location_with_labwares) }
  let!(:location_with_children)     { create(:unordered_location_with_labwares_and_children) }

  it "will not be valid without a valid user" do
    create_empty_location.submit(params.merge(empty_location_form:
      { "location_barcode" => location.barcode }))
    expect(create_empty_location.errors.full_messages).to include("User #{I18n.t('errors.messages.existence')}")
  end

  it "will not be valid without a location" do
    create_empty_location.submit(params.merge(empty_location_form:
      { "location_barcode" => 'lw-no-location-here', "user_code" => user.swipe_card_id }))
    expect(create_empty_location.errors.full_messages).to include("Location with barcode lw-no-location-here does not exist")
  end

  it "will not be valid if the locations has child locations" do
    create_empty_location.submit(params.merge(empty_location_form:
      { "location_barcode" => location_with_children.barcode, "user_code" => user.swipe_card_id }))
    expect(create_empty_location.errors.full_messages).to include("Location with barcode #{location_with_children.barcode} has child locations")
  end

  it "when valid will remove all of the labwares from the location" do
    create_empty_location.submit(params.merge(empty_location_form:
      { "location_barcode" => location.barcode, "user_code" => user.swipe_card_id }))
    expect(location.reload.labwares).to be_empty
  end

  it "will strip the location barcode" do
    create_empty_location.submit(params.merge(empty_location_form:
      { "location_barcode" => location.barcode + "\n", "user_code" => user.swipe_card_id }))
    expect(location.reload.labwares).to be_empty
  end
end
