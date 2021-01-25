# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserForm, type: :model do
  let!(:scientist) { create(:scientist) }
  let!(:technician) { create(:technician) }
  let!(:administrator) { create(:administrator) }
  let(:params) { ActionController::Parameters.new(controller: "users", action: "update") }

  subject { UserForm.new(technician) }

  it "if user is unauthorised (scientist) then swipe card id should not be updated" do
    expect { # rubocop:todo Lint/AmbiguousBlockAssociation
      UserForm.new(scientist).submit(params.merge(user: { swipe_card_id: '12345', user_code: scientist.swipe_card_id }))
    }.to_not change { technician.reload.swipe_card_id }
  end

  it "if user is updated but swipe card id is left blank then swipe card id should not be updated" do
    expect { # rubocop:todo Lint/AmbiguousBlockAssociation
      subject.submit(params.merge(user: { swipe_card_id: nil, user_code: administrator.swipe_card_id }))
    }.to_not change { technician.reload.swipe_card_id }
  end

  it "if user is updated but barcode is left blank then barcode should not be updated" do
    expect { # rubocop:todo Lint/AmbiguousBlockAssociation
      subject.submit(params.merge(user: { barcode: nil, user_code: administrator.swipe_card_id }))
    }.to_not change { technician.reload.barcode }
  end
end
