FactoryGirl.define do
  factory :location do
    sequence(:name) {|n| "Location #{n}" }
    location_type_id { create(:location_type).id }
    parent nil
    team nil

    factory :location_with_parent do
      parent { FactoryGirl.create(:location)}
    end

    factory :unordered_location, class: "UnorderedLocation" do
      factory :unordered_location_with_parent do
        parent { FactoryGirl.create(:location)}
      end

      factory :unordered_location_with_labwares do

        parent { FactoryGirl.create(:location)}

        after(:create) do |location, evaluator|
          1.upto(5) do |n|
            FactoryGirl.create(:labware, location: location)
          end
        end
      end

      factory :unordered_location_with_children do

        after(:create) do |location, evaluator|
          1.upto(5) do |n|
            FactoryGirl.create(:location, parent: location)
          end
        end
      end

      factory :unordered_location_with_labwares_and_children do

        parent { FactoryGirl.create(:location)}

        after(:create) do |location, evaluator|
          1.upto(5) do |n|
            FactoryGirl.create(:location, parent: location)
            FactoryGirl.create(:labware, location: location)
          end
        end

      end
    end

    factory :ordered_location, class: "OrderedLocation" do

      rows 4
      columns 4

      factory :ordered_location_with_parent do
        parent { FactoryGirl.create(:location)}
      end

      factory :ordered_location_with_labwares do

        parent { FactoryGirl.create(:location)}

        after(:create) do |location, evaluator|
          location.coordinates.each do |coordinate|
            coordinate.fill(FactoryGirl.create(:labware))
          end
        end
      end

    end

    factory :location_with_audits do
      transient do
        user { create(:user)}
      end

      after(:create) do |location, evaluator|
        1.upto(5) do |n|
          FactoryGirl.create(:audit, auditable_type: location.class,
            auditable_id: location.id, user: evaluator.user, record_data: location)
        end
      end
    end

    factory :unknown_location, class: "UnknownLocation" do

    end

  end

end