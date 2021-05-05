# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "mocha/minitest"

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  include FactoryBot::Syntax::Methods
end
