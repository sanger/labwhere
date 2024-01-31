# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Labwhere
  class Application < Rails::Application
    config.load_defaults 6.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    # convert dates and times to correct time zone
    config.time_zone = 'London'
    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_attributes = false

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # redirect errors to errors controller
    config.exceptions_app = routes

    # TODO. There should be no need for lib. We should not need to autoload anything in app
    # Something is not quite right so needs investigating.
    config.autoload_paths += %W[#{config.root}/app/lib]

    config.autoload_paths += %W[#{config.root}/app/lib/utils #{config.root}/app/lib/validators]

    config.autoload_paths += %W[#{config.root}/app/models/users #{config.root}/app/models/locations
                                #{config.root}/app/models/restrictions]

    config.autoload_paths += %W[#{config.root}/app/lib/label_printing #{config.root}/app/models/labware_collection]

    config.mailer = YAML.load_file(Rails.root.join('config/mailer.yml'))[Rails.env]

    config.label_templates = Rails.application.config_for(:label_templates)

    config.eager_load_paths += %W[#{config.root}/app/lib/utils #{config.root}/app/lib/validators
                                  #{config.root}/app/models/users #{config.root}/app/models/locations
                                  #{config.root}/app/models/restrictions #{config.root}/app/lib/label_printing
                                  #{config.root}/app/models/labware_collection]

    # replace fixtures with factory bot
    config.generators do |g|
      g.test_framework :rspec,
                       fixtures: true,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false,
                       controller_specs: false,
                       request_specs: true
      g.fixture_replacement :factory_bot, dir: 'spec/factories'

      # Fix for Psych::DisallowedClass. Added the four top classes as this may guard against hidden errors.
      config.active_record.yaml_column_permitted_classes = [Symbol, Hash, Array, ActiveSupport::HashWithIndifferentAccess]
    end

    # RabbitMQ config
    config.bunny = config_for(:bunny)

    Rails.application.config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get]
      end
    end
  end
end
