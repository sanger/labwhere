# frozen_string_literal: true

FactoryBot.define do
  factory :labware_collection_unordered_location, class: LabwareCollection::UnorderedLocation do
    location { FactoryBot.create(:location_with_parent) }
    user { FactoryBot.create(:administrator) }
    labwares { (FactoryBot.build_list(:labware, 3) + FactoryBot.create_list(:labware_with_location, 2)).join_barcodes }

    initialize_with { new(location: location, user: user, labwares: labwares) }

    after(:build) { |labware_collection| labware_collection.push }
  end
end
