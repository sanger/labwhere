# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    sequence(:name) { |n| "Location #{n}" }
    location_type_id { create(:location_type).id }
    internal_parent { nil }
    parent { nil }
    team { nil }

    factory :location_with_parent do
      parent { FactoryBot.create(:location) }
    end

    factory :unordered_location, class: 'UnorderedLocation' do
      factory :unordered_location_with_parent do
        parent { FactoryBot.create(:location) }
      end

      factory :unordered_location_with_labwares do
        parent { FactoryBot.create(:location) }

        after(:create) do |location, _evaluator|
          1.upto(5) do |_n|
            FactoryBot.create(:labware, location: location)
          end
        end
      end

      factory :unordered_location_with_children do
        after(:create) do |location, _evaluator|
          1.upto(5) do |_n|
            FactoryBot.create(:location, parent: location)
          end
          location.reload
        end
      end

      factory :unordered_location_with_labwares_and_children do
        parent { FactoryBot.create(:location) }

        after(:create) do |location, _evaluator|
          1.upto(5) do |_n|
            FactoryBot.create(:location, parent: location)
            FactoryBot.create(:labware, location: location)
          end
          # The children_count cache will have been updated
          location.reload
        end
      end
    end

    factory :ordered_location, class: 'OrderedLocation' do
      rows { 4 }
      columns  { 4 }

      factory :ordered_location_with_parent do
        parent { FactoryBot.create(:location) }
      end

      factory :ordered_location_with_labwares do
        parent { FactoryBot.create(:location) }

        after(:create) do |location, _evaluator|
          location.coordinates.each do |coordinate|
            coordinate.fill(FactoryBot.create(:labware))
          end

          location.reload
        end
      end
    end

    factory :location_with_audits do
      transient do
        user { create(:user) }
      end

      after(:create) do |location, evaluator|
        1.upto(5) do |_n|
          FactoryBot.create(:audit, auditable_type: location.class,
                                    auditable_id: location.id, user: evaluator.user, record_data: location)
        end
      end
    end

    factory :unknown_location, class: 'UnknownLocation'
  end
end
