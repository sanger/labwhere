# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:login) { |n| "User:#{n}" }
    swipe_card_id { "SwipeCardId:#{login}" }
    barcode { "Barcode:#{login}" }
    team

    factory :administrator, class: "Administrator"

    factory :technician, class: "Technician"

    factory :scientist, class: "Scientist"

    factory :user_with_audits do
      transient do
        user { create(:user) }
      end

      after(:create) do |user, evaluator|
        1.upto(5) do |_n|
          FactoryBot.create(:audit, auditable_type: user.class,
                                    auditable_id: user.id, user: evaluator.user, record_data: user)
        end
      end
    end
  end
end
