# frozen_string_literal: true

# Broker setup
Broker::Handle = Messages::Broker.new(Rails.configuration.bunny)
