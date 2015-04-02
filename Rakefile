# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

# Adds lib to rake test command.
["functional"].each do |folder|
  namespace :test do
    Rails::TestTask.new(folder => "test:prepare") do |t|
      t.pattern = "test/#{folder}/**/*_test.rb"
    end
  end

  Rake::Task["test:run"].enhance ["test:#{folder}"]
  
end
