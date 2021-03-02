# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmptyLocationForm, type: :model do
  let(:new_form) { EmptyLocationForm.new }
  let!(:tech_swipe_card_id)         { generate(:swipe_card_id) }
  let!(:technician)                 { create(:technician, swipe_card_id: tech_swipe_card_id) }
  let!(:sci_swipe_card_id)          { generate(:swipe_card_id) }
  let!(:scientist)                  { create(:scientist, swipe_card_id: sci_swipe_card_id) }
  let(:params)                      { ActionController::Parameters.new(controller: "empty_locations", action: "create") }
  let(:location)                    { create(:unordered_location_with_labwares) }
  let!(:num_labwares)               { location.labwares.count }
  let!(:location_with_children)     { create(:unordered_location_with_labwares_and_children) }

  it "will not be valid without a valid user" do
    new_form.submit(params.merge(empty_location_form:
      { "location_barcode" => location.barcode }))
    expect(new_form.errors.full_messages).to include("User #{I18n.t('errors.messages.existence')}")
  end

  it "will not be valid with an authorised user (scientist)" do
    new_form.submit(params.merge(empty_location_form:
      { "location_barcode" => 'lw-no-location-here', "user_code" => sci_swipe_card_id }))
    expect(new_form.errors.full_messages).to include("Location with barcode lw-no-location-here does not exist")
  end

  it "will not be valid without a location" do
    new_form.submit(params.merge(empty_location_form:
      { "location_barcode" => 'lw-no-location-here', "user_code" => tech_swipe_card_id }))
    expect(new_form.errors.full_messages).to include("Location with barcode lw-no-location-here does not exist")
  end

  it "will not be valid if the locations has child locations" do
    new_form.submit(params.merge(empty_location_form:
      { "location_barcode" => location_with_children.barcode, "user_code" => tech_swipe_card_id }))
    expect(new_form.errors.full_messages).to include("Location with barcode #{location_with_children.barcode} has child locations")
  end

  it "will strip the location barcode" do
    new_form.submit(params.merge(empty_location_form:
      { "location_barcode" => "#{location.barcode}\n", "user_code" => tech_swipe_card_id }))
    expect(location.reload.labwares).to be_empty
  end

  context 'when everything is valid' do
    let!(:submitted_form) do
      new_form.submit(params.merge(empty_location_form:
                            { "location_barcode" => location.barcode, "user_code" => tech_swipe_card_id }))
    end

    it "will remove all of the labwares from the location" do
      expect(location.reload.labwares).to be_empty
    end

    it "will add audit records for the location and labwares" do
      audits = Audit.last(num_labwares + 1)
      # location
      expect(audits.first.user).to eq(technician)
      expect(audits.first.action).to eq(AuditAction::REMOVE_ALL_LABWARES)
      # labwares
      expect(audits.slice(1, num_labwares).map(&:action).uniq).to eq([AuditAction::EMPTY_LOCATION])
    end
  end
end
