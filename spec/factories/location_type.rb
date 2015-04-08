FactoryGirl.define do
  factory :location_type do
    sequence(:name) {|n| "Location Type #{n}" }
  end
end