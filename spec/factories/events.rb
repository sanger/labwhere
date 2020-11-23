# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    labware { create(:labware_with_location) }
    audit { create(:audit_of_labware, labware: labware) }
  end
end
