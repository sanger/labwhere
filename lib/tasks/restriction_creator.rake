# frozen_string_literal: true

require Rails.root.join('app/lib/restriction_creator/restriction_creator.rb')

namespace :restrictions do
  desc "create restrictions"
  task create: :environment do |_t|
    if Restriction.all.empty? && LocationTypesRestriction.all.empty?
      restrictions = YAML.load_file(Rails.root.join("app/data/restrictions.yaml"))
      RestrictionCreator.new(restrictions).run!
    end
  end
end
