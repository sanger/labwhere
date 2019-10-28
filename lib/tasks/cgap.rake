# Dir[File.join(Rails.root,"lib","cgap","migrations","*.rb")].each { |f| require f }
# require File.join(Rails.root,"lib","cgap","cgap")

# namespace :cgap do

#   namespace :db do
#     desc "run the migrations"
#     task :migrate => :environment do |t|
#       ActiveRecord::Base.establish_connection :cgap
#       CreateCgapLocations.new.change
#       CreateCgapLabwares.new.change
#       CreateCgapStorage.new.change
#     end

#     desc "remove all of the data"
#     task :clear => :environment do |t|
#       Cgap::Storage.delete_all
#       Cgap::Location.delete_all
#       Cgap::Labware.delete_all
#     end
#   end

#   namespace :data do

#     desc "migrate data"
#     task :migrate => :environment do |t|
#       Cgap::MigrateTopLevelLocations.run!
#       Cgap::MigrateLocations.run!
#       Cgap::MigrateLabwares.run!
#     end
#   end

# end
