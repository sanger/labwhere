FactoryBot.define do
  factory :search do
    sequence(:term) {|n| "Search #{n}" }
  end

end
