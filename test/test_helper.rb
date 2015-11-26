ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"

Dir[File.join(Rails.root,"lib","cgap","models","*.rb")].each { |f| require f }
Dir[File.join(Rails.root,"lib","location_creator","*.rb")].each { |f| require f }


class ActiveSupport::TestCase

  ActiveRecord::Migration.check_pending!

end