# frozen_string_literal: true

FactoryBot.define do
  factory :labware_collection_unordered_location, class: LabwareCollection::UnorderedLocation do
    location { FactoryBot.create(:location_with_parent) }
    user { FactoryBot.create(:administrator) }
    labwares do
      (FactoryBot.build_list(:labware, 3) + FactoryBot.create_list(:labware_with_location, 2)).extract_barcodes
    end

    initialize_with { new(location: location, user: user, labwares: labwares) }

    after(:build, &:push)
  end
end
