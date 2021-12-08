# frozen_string_literal: true

require 'bunny'
require 'ostruct'

module Messages
  # This class should control connection, exchange, queues and publishing to the broker
  class Broker
    attr_accessor :connection
    attr_reader :channel, :exchange, :bunny_config

    def initialize(bunny_config)
      @bunny_config = OpenStruct.new(bunny_config) # rubocop:todo Style/OpenStructUse
    end

    # This module provides a way of performing the create_connection call only
    # once when the value is nil. If we want to reset this, we have to
    # set back connection_checked=nil
    module ConnectionCheckMemoization
      attr_writer :connection_checked

      # This method will try to create a new Rabbitmq connection if it has
      # not been attempted before. It is considered that it has not been
      # attempted when @connection_checked = nil.
      # The method will give a boolean value to @connection_checked so
      # it will not try to connect again in next calls of this method unless
      # is reset again.
      def check_connection_and_connect
        @connection_checked = create_connection if @connection_checked.nil?
        @connection_checked
      end
    end
    include ConnectionCheckMemoization

    def create_connection
      return false unless @bunny_config.enabled

      connected? || connect
    end

    def connected?
      @connection&.connected?
    end

    def connect
      connect!
    end

    def connect!
      start_connection
      open_channel
      instantiate_exchange
      true
    rescue StandardError => e
      Rails.logger.error("Cannot connect with RabbitMQ: #{e.message}")
      ExceptionNotifier.notify_exception(e)
      false
    end

    def start_connection
      @connection = Bunny.new host: bunny_config.broker_host,
                              port: bunny_config.broker_port,
                              username: bunny_config.broker_username,
                              password: bunny_config.broker_password,
                              vhost: bunny_config.vhost,
                              connection_timeout: 10 # Seconds to wait for connection
      @connection.start
    end

    def open_channel
      @channel = @connection.create_channel
    end

    def instantiate_exchange
      @exchange = @channel.topic(bunny_config.exchange, passive: true)
    end

    def publish(message)
      if check_connection_and_connect
        _publish(message)
      else
        Rails.logger.error("Not connected to RabbitMQ")
        Rails.logger.error("Message not published: #{message.payload}")
      end
    end

    private

    def _publish(message)
      exchange.publish(message.payload, routing_key: bunny_config['routing_key'])
    rescue StandardError => e
      Rails.logger.error("Cannot publish to RabbitMQ: #{e.message}")
      ExceptionNotifier.notify_exception(e)
    end
  end
end
