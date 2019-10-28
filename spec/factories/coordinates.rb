FactoryBot.define do
  factory :coordinate do
    location { create(:location_with_parent) }
    position 1
    row 1
    column 1
    labware nil
  end
end
