FactoryGirl.define do
  factory :labware do
    sequence(:barcode) {|n| "Labware:#{n}" }
    location nil

    factory :labware_with_audits do
      transient do
        user { create(:user)}
      end

      after(:create) do |labware, evaluator|
        1.upto(5) do |n|
          FactoryGirl.create(:audit, auditable_type: labware.class, 
            auditable_id: labware.id, user: evaluator.user, record_data: labware)
        end
      end
    end

  end

end
