FactoryBot.define do
  factory :user do
    sequence(:login) {|n| "User:#{n}" }
    swipe_card_id { "SwipeCardId:#{login}" }
    barcode { "Barcode:#{login}" }
    team

    factory :administrator, class: "Administrator" do
    end

    factory :scientist, class: "Scientist" do
    end

    factory :user_with_audits do
      transient do
        user { create(:user)}
      end

      after(:create) do |user, evaluator|
        1.upto(5) do |n|
          FactoryBot.create(:audit, auditable_type: user.class,
            auditable_id: user.id, user: evaluator.user, record_data: user)
        end
      end
    end
  end

end
