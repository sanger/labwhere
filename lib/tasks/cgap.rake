Dir[File.join(Rails.root,"lib","cgap","migrations","*.rb")].each { |f| require f }

namespace :cgap do

  namespace :db do
    desc "run the migrations"
    task :migrate => :environment do |t|
      ActiveRecord::Base.establish_connection :cgap
      CreateCgapLocations.new.change
      CreateCgapLabwares.new.change
      CreateCgapStorage.new.change
    end

    desc "remove all of the data"
    task :clear => :environment do |t|
      CgapStorage.delete_all
      CgapLocation.delete_all
      CgapLabware.delete_all
    end
  end

  namespace :data do

    desc "migrate data"
    task :migrate => :environment do |t|
      MigrateTopLevelLocations.run!
      MigrateLocations.run!
      MigrateLabwares.run!
    end
  end
  
 
end