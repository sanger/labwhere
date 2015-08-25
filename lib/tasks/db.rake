namespace :db do

  desc "clear the database"
  task :clear => :environment do |t|
    Rails.application.eager_load!
    models = ActiveRecord::Base.descendants
    models.each do |model|
      model.delete_all
    end
  end

  desc "reload data. Will clear all data out first"
  task :reload => :environment do |t|
    Rake::Task["db:clear"].execute
    location_types = YAML.load_file(File.join(Rails.root,"config","location_types.yml"))
    location_types.each do |k, v|
      LocationType.create(v)
    end
    team = Team.create(name: "Team1", number: 1)
    Administrator.create(login: "admin", swipe_card_id: "1234", barcode: "admin-1", team: team)
  end
end