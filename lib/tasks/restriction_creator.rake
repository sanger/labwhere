# frozen_string_literal: true

Dir[Rails.root.join('lib/restriction_creator/*.rb')].each { |f| require f }

namespace :restrictions do
  desc "create restrictions"
  task create: :environment do |_t|
    if Restriction.all.empty? && LocationTypesRestriction.all.empty?
      restrictions = YAML.load_file(Rails.root.join("app/data/restrictions.yaml"))
      RestrictionCreator.new(restrictions).run!
    end
  end
end
