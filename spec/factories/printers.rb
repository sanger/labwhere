FactoryGirl.define do
  factory :printer do
    sequence(:name) {|n| "Printer #{n}" }
    uuid { SecureRandom.uuid }

    factory :printer_with_audits do
      transient do
        user { create(:user)}
      end

      after(:create) do |printer, evaluator|
        1.upto(5) do |n|
          FactoryGirl.create(:audit, auditable_type: printer.class, 
            auditable_id: printer.id, user: evaluator.user, record_data: printer)
        end
      end
    end
  end

end
