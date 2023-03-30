# frozen_string_literal: true

require Rails.root.join('app/lib/utils/dependent_loader.rb')

DependentLoader.start(:restrictions) do |on|
  on.success do
    DependentLoader.start(:location_types_restrictions) do |and_on|
      and_on.success do
        restrictions = YAML.load_file(Rails.root.join('app/data/restrictions.yaml'))
        RestrictionCreator.new(restrictions).run!
      end
    end
  end
end
