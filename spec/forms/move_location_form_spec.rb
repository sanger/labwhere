# frozen_string_literal: true

require "rails_helper"

RSpec.describe MoveLocationForm, type: :model do
  let(:create_move_location)  { MoveLocationForm.new }
  let!(:user)                 { create(:scientist) }
  let(:params)                { ActionController::Parameters.new(controller: "move_locations", action: "create") }
  let(:child_locations)       { create_list(:location_with_parent, 5) }
  let!(:parent_location)      { create(:location_with_parent) }

  it "will not be valid without a valid user" do
    create_move_location.submit(params.merge(move_location_form:
      { "parent_location_barcode" => parent_location.barcode, "child_location_barcodes" => child_locations.join_barcodes }))
    expect(create_move_location.errors.full_messages).to include("User #{I18n.t('errors.messages.existence')}")
  end

  it "will not be valid without a location" do
    create_move_location.submit(params.merge(move_location_form:
      { "parent_location_barcode" => 'lw-no-location-here', "child_location_barcodes" => child_locations.join_barcodes, "user_code" => user.swipe_card_id }))
    expect(create_move_location.errors.full_messages).to include("Parent location #{I18n.t('errors.messages.existence')}")
  end

  it "will not be valid unless all of the child locations exist" do
    create_move_location.submit(params.merge(move_location_form:
      { "parent_location_barcode" => parent_location.barcode, "child_location_barcodes" => "#{child_locations.join_barcodes}\nlw-no-location-here", "user_code" => user.swipe_card_id }))
    expect(create_move_location.errors.full_messages).to include("Location with barcode lw-no-location-here #{I18n.t('errors.messages.existence')}")
  end

  it "when valid will make add all locations to parent" do
    create_move_location.submit(params.merge(move_location_form:
      { "parent_location_barcode" => parent_location.barcode, "child_location_barcodes" => child_locations.join_barcodes, "user_code" => user.swipe_card_id }))
    child_locations.each do |location|
      location.reload
      expect(location.parent).to eq(parent_location)
      expect(parent_location.children).to include(location)
    end
  end

  describe 'audit records' do
    let!(:locations_with_labwares) { create_list(:unordered_location_with_labwares, 5) }

    it "will be added for the labwares in the location" do
      create_move_location.submit(params.merge(move_location_form:
        { "parent_location_barcode" => parent_location.barcode, "child_location_barcodes" => locations_with_labwares.join_barcodes, "user_code" => user.swipe_card_id }))
      locations_with_labwares.each do |location|
        location.reload
        expect(location.labwares.all? { |labware| labware.audits.count == 1 }).to be_truthy
        expect(location.labwares.first.audits.first.action).to eq("moved to #{parent_location.location_type.name}")
      end
    end
  end
end
