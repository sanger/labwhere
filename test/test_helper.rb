ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # Allow use of build and create without FactoryGirl
  include FactoryGirl::Syntax::Methods

  # Allow use of path and url helpers
  include Rails.application.routes.url_helpers
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  # Ensure that capybara uses the correct driver and visits the correct host.
  Capybara.configure do |config|
    config.run_server = false
    config.default_driver = :selenium
    config.app_host = 'http://localhost:9292'
  end

end
