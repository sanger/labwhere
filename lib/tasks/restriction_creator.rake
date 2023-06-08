# frozen_string_literal: true

# This only creates restrictions if there are no restrictions in the database
# It does not update outdated or removed restrictions.
namespace :restrictions do
  desc 'create restrictions'
  task create: :environment do |_t|
    if Restriction.all.empty? && LocationTypesRestriction.all.empty?
      restrictions = YAML.load_file(Rails.root.join('app/data/restrictions.yaml'))
      RestrictionCreator.new(restrictions).run!
    end
  end
end
