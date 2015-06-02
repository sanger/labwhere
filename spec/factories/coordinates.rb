FactoryGirl.define do
  factory :coordinate do
    sequence(:name) {|n| "#{n}" }
  end

end
