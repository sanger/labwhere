FactoryGirl.define do
  factory :labware do
    sequence(:barcode) {|n| "Labware:#{n}" }
    location nil
  end

end
