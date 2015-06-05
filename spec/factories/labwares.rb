FactoryGirl.define do
  factory :labware do
    sequence(:barcode) {|n| "Labware:#{n}" }
    location nil
    coordinate nil

    factory :labware_with_histories do

      coordinate { create(:coordinate) }

      after(:create) do |labware, evaluator|
        1.upto(5) do |n|
          FactoryGirl.create(:history, labware: labware, scan: FactoryGirl.create(:scan))
        end
      end
    end

  end

end
