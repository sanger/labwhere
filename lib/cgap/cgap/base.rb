class Cgap::Base < ActiveRecord::Base
  self.abstract_class = true

  # TODO: The following statement causes errors when the rake task is run and when the app is
  # deployed.
  # establish_connection  Rails.configuration.database_configuration["cgap"]
  # establish_connection  :cgap

end