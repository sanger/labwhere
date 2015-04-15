FactoryGirl.define do
  factory :location do
    sequence(:name) {|n| "Location #{n}" }
    container true
    active true
    location_type
    parent nil

    factory :location_with_parent do
      parent { FactoryGirl.create(:location)}
    end

    factory :location_unknown do
      name "UNKNOWN"
    end
  end



end
