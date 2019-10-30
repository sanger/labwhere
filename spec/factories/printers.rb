# frozen_string_literal: true

FactoryBot.define do
  factory :printer do
    sequence(:name) { |n| "Printer #{n}" }

    factory :printer_with_audits do
      transient do
        user { create(:user) }
      end

      after(:create) do |printer, evaluator|
        1.upto(5) do |_n|
          FactoryBot.create(:audit, auditable_type: printer.class,
                                    auditable_id: printer.id, user: evaluator.user, record_data: printer)
        end
      end
    end
  end
end
