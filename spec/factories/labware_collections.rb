FactoryGirl.define do
  factory :labware_collection, class: LabwareCollection do
    location { FactoryGirl.create(:location_with_parent)}
    user { FactoryGirl.create(:administrator) }
    labwares { (FactoryGirl.build_list(:labware, 3) + FactoryGirl.create_list(:labware_with_location, 2)).join_barcodes }

    initialize_with { new(location, user, labwares) }

    after(:build) { |labware_collection| labware_collection.push }
  end
end