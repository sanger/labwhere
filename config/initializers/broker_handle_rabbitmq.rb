# frozen_string_literal: true

require Rails.root.join('app/messages/messages.rb')
require Rails.root.join('app/models/broker.rb')
require Rails.root.join('app/messages/messages/broker.rb')

# Broker setup
Broker::Handle = Messages::Broker.new(Rails.configuration.bunny)
