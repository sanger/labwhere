Dir[File.join(Rails.root,"lib","cgap","migrations","*.rb")].each { |f| require f }

namespace :cgap do
  
  desc "run the migrations"
  task :migrate => :environment do |t|
    ActiveRecord::Base.establish_connection :cgap
    CreateCgapTopLocations.new.change
    CreateCgapSubLocations.new.change
    CreateCgapLabwares.new.change
  end
end