# frozen_string_literal: true

namespace :db do
  desc "clear the database"
  task clear: :environment do |_t|
    Rails.application.eager_load!
    models = ActiveRecord::Base.descendants
    models.each(&:delete_all)
  end

  desc "reload data. Will clear all data out first"
  task reload: :environment do |_t|
    Rake::Task["db:clear"].execute
    location_types = YAML.load_file(Rails.root.join('config/location_types.yml'))
    location_types.each do |_k, v|
      LocationType.create(v)
    end
    team = Team.create(name: "Team1", number: 1)
    Administrator.create(login: "admin", swipe_card_id: "1234", barcode: "admin-1", team: team)
  end
end
