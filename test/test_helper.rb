ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "#{Rails.root}/lib/cgap/cgap"

class ActiveSupport::TestCase

  ActiveRecord::Migration.check_pending!

  include FactoryGirl::Syntax::Methods

end

require 'mocha/mini_test'