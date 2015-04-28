ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require "capybara/rails"
require "minitest/rails/capybara"

Dir[Rails.root.join('test', 'support', '*.rb')].each  { |file| require file }

class ActiveSupport::TestCase

  ActiveRecord::Migration.check_pending!
  
  include FactoryGirl::Syntax::Methods
  
  DatabaseCleaner.strategy = :truncation
  before { DatabaseCleaner.start }
  after  { DatabaseCleaner.clean }

  # Allow use of path and url helpers
  include Rails.application.routes.url_helpers

end

class Capybara::Rails::TestCase

  include Rails.application.routes.url_helpers 
  include Capybara::DSL
  include Capybara::Assertions
  include FactoryGirl::Syntax::Methods
  
  DatabaseCleaner.strategy = :truncation
  before { DatabaseCleaner.start }
  after  { DatabaseCleaner.clean } 
end