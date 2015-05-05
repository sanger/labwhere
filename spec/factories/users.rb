FactoryGirl.define do
  factory :user do
    sequence(:login) {|n| "User:#{n}" }
    sequence(:swipe_card) {|n| "SwipeCard:#{n}" }
    sequence(:barcode) {|n| "Barcode:#{n}" }

    factory :admin, class: "Admin" do
    end

    factory :standard, class: "Standard" do
    end
  end

end
