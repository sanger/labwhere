# frozen_string_literal: true

require Rails.root.join('app/lib/utils/dependent_loader.rb')

DependentLoader.start(:location_types) do |on|
  on.success do
    LocationType.create(
      [
        { name: 'Site' },
        { name: 'Building' },
        { name: 'Room' },
        { name: 'Freezer -80C' },
        { name: 'Incubator 37C' },
        { name: 'Shelf' },
        { name: 'Box' },
        { name: 'Bin' }
      ]
    )
  end
end
