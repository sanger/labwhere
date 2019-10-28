FactoryBot.define do
  factory :location_type do
    sequence(:name) { |n| "Location Type #{n}" }

    after(:create) do |location_type, _evaluator|
      create_list(:restriction, 3, location_type: location_type)
    end

    factory :location_type_with_audits do
      transient do
        user { create(:user) }
      end

      after(:create) do |location_type, evaluator|
        1.upto(5) do |_n|
          FactoryBot.create(:audit, auditable_type: location_type.class,
                                    auditable_id: location_type.id, user: evaluator.user, record_data: location_type)
        end
      end
    end

    factory :location_type_with_locations do
      after(:create) do |location_type, _evaluator|
        1.upto(5) do |_n|
          FactoryBot.create(:location_with_parent, location_type: location_type)
        end
      end
    end
  end
end
