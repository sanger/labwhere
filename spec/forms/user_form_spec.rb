# frozen_string_literal: true

require "rails_helper"
require 'digest/sha1'

RSpec.describe UserForm, type: :model do
  let!(:sci_swipe_card_id) { generate(:swipe_card_id) }
  let!(:scientist) { create(:scientist, swipe_card_id: sci_swipe_card_id) }
  let!(:tech_swipe_card_id) { generate(:swipe_card_id) }
  let!(:technician) { create(:technician, swipe_card_id: tech_swipe_card_id) }
  let!(:admin_swipe_card_id) { generate(:swipe_card_id) }
  let!(:administrator) { create(:administrator, swipe_card_id: admin_swipe_card_id) }
  let(:params) { ActionController::Parameters.new(controller: "users", action: "update") }

  subject { UserForm.new(technician) }

  it "if user is unauthorised (scientist) then swipe card id should not be updated" do
    expect {
      UserForm.new(scientist).submit(params.merge(user: { swipe_card_id: '12345', user_code: sci_swipe_card_id }, commit: "Update User"))
    }.to_not change { technician.reload.swipe_card_id }
  end

  it "if user is authorised and swipe card is not left blank it should be updated" do
    expect {
      subject.submit(params.merge(user: { swipe_card_id: '12345', user_code: admin_swipe_card_id }, commit: "Update User"))
    }.to change { technician.reload.swipe_card_id }.to(Digest::SHA1.hexdigest('12345'))
  end

  it "if user is authorised but swipe card id is left blank then swipe card id should not be updated" do
    expect {
      subject.submit(params.merge(user: { swipe_card_id: nil, user_code: admin_swipe_card_id }, commit: "Update User"))
    }.to_not change { technician.reload.swipe_card_id }
  end

  it "if user is authorised but barcode is left blank then barcode should not be updated" do
    expect {
      subject.submit(params.merge(user: { barcode: nil, user_code: admin_swipe_card_id }, commit: "Update User"))
    }.to_not change { technician.reload.barcode }
  end
end
