FactoryGirl.define do
  factory :printer do
    sequence(:name) {|n| "Printer #{n}" }
    uuid { SecureRandom.uuid }
  end

end
