FactoryGirl.define do
  factory :labware_collection_unordered_location, class: LabwareCollection::UnorderedLocation do
    location { FactoryGirl.create(:location_with_parent)}
    user { FactoryGirl.create(:administrator) }
    labwares { (FactoryGirl.build_list(:labware, 3) + FactoryGirl.create_list(:labware_with_location, 2)).join_barcodes }

    initialize_with { new(location: location, user: user, labwares: labwares) }

    after(:build) { |labware_collection| labware_collection.push }
  end
end