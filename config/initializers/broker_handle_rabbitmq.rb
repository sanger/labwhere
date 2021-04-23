# Broker setup
Broker::Handle = Messages::Broker.new(Rails.configuration.bunny)
Broker::Handle.create_connection if Rails.configuration.bunny['enabled']
