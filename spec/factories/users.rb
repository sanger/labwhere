FactoryGirl.define do
  factory :user do
    sequence(:login) {|n| "User:#{n}" }
    swipe_card_id { "SwipeCardId:#{login}" }
    barcode { "Barcode:#{login}" }
    team

    factory :admin, class: "Admin" do
    end

    factory :standard, class: "Standard" do
    end

    factory :user_with_audits do
      transient do
        user { create(:user)}
      end

      after(:create) do |user, evaluator|
        1.upto(5) do |n|
          FactoryGirl.create(:audit, auditable_type: user.class, 
            auditable_id: user.id, user: evaluator.user, record_data: user.to_json)
        end
      end
    end
  end

end
