# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'with_model'
require 'selenium/webdriver'
require 'support/helpers'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Rails.root.glob('spec/support/**/*.rb').each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  include Helpers
  include FactoryBot::Syntax::Methods

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = Rails.root.join('spec/fixtures')

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.include Rails.application.routes.url_helpers

  config.include Capybara::DSL

  config.extend WithModel

  config.include_context 'shared helpers', include_shared: true

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    Capybara.reset_sessions!
    DatabaseCleaner.clean
  end

  Capybara.server = :puma, { Silent: true }

  Capybara.add_selector(:data_behavior) do
    xpath { |name| XPath.css("[data-behavior='#{name}']") }
  end

  Capybara.add_selector(:data_id) do
    xpath { |id| XPath.css("[data-id='#{id}']") }
  end

  Capybara.add_selector(:data_output) do
    xpath { |id| XPath.css("[data-output='#{id}']") }
  end

  Capybara.register_driver :headless_chrome do |app|
    # Fix for error updating to Chrome 128
    # https://github.com/SeleniumHQ/selenium/issues/14453
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless=new')
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1280,800')
    options.add_argument('--disable-search-engine-choice-screen')
    Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      options: options
    )
  end

  Selenium::WebDriver.logger.level = :error
  Capybara.javascript_driver = :headless_chrome
end
