# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    user { create(:user) }
    labware { create(:labware_with_location) }
    action { 'labwhere_scanned_in' }
  end
end
