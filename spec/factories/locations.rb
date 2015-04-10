FactoryGirl.define do
  factory :location do
    sequence(:name) {|n| "Location #{n}" }
    container true
    active true
    location_type
  end

end
