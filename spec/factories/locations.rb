FactoryGirl.define do
  factory :location do
    sequence(:name) {|n| "Location #{n}" }
    location_type_id { create(:location_type).id }
    parent nil
    status { Location.statuses.keys.first }

    factory :location_with_parent do
      parent { FactoryGirl.create(:location)}
    end

    factory :location_with_audits do
      transient do
        user { create(:user)}
      end

      after(:create) do |location, evaluator|
        1.upto(5) do |n|
          FactoryGirl.create(:audit, auditable_type: location.class, 
            auditable_id: location.id, user: evaluator.user, record_data: location.to_json)
        end
      end
    end

  end

end