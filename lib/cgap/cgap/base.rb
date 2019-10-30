# frozen_string_literal: true

class Cgap::Base < ActiveRecord::Base
  self.abstract_class = true

  # This is a hack to ensure that the configurations are loaded when the rake task is run.
  if configurations.empty?
    ActiveRecord::Base.configurations = Rails.configuration.database_configuration
  end

  # TODO: The following statement causes errors when the rake task is run and when the app is
  # deployed.
  establish_connection :cgap
end
