# frozen_string_literal: true

FactoryBot.define do
  factory :audit do
    transient do
      location { create(:location) }
    end
    auditable_type { location.class }
    action { "create" }
    record_data  { location }
    auditable_id { location.id }
    user

    factory :audit_of_labware do
      transient do
        labware { create(:labware_with_location) }
      end
      auditable_type { labware.class }
      action { "create" }
      record_data  { labware }
      auditable_id { labware.id }
      user
    end
  end
end
