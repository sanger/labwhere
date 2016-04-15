class Cgap::Base < ActiveRecord::Base
  self.abstract_class = true

  establish_connection  Rails.configuration.database_configuration["cgap"]

end