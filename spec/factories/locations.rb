FactoryGirl.define do
  factory :location do
    sequence(:name) {|n| "Location #{n}" }
    location_type_id { create(:location_type).id }
    parent nil

    factory :location_with_parent do
      parent { FactoryGirl.create(:location)}
    end

  end

end