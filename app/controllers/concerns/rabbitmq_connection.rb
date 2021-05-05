# frozen_string_literal: true

##
# Resets the connection check on every request so it will only try to create
# a new Rabbitmq connection for each new HTTP request. Once a Rabbitmq connection
# has been attempted in the current HTTP request, any access to Rabbitmq will not
# retry checking the connection and connecting again until the next time there is
# a HTTP request.
module RabbitmqConnection
  extend ActiveSupport::Concern

  included do
    before_action :reset_connection_checked
  end

  # Resets the memoized value of the Rabbitmq connection checked.
  def reset_connection_checked
    Broker::Handle.connection_checked = nil if Broker::Handle
  end
end
