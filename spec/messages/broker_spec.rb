# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Messages::Broker do
  let(:bunny) { double('Bunny') }

  let(:bunny_config) do
    {
      enabled: true
    }
  end

  let(:message) do
    double('message', payload: 'some stuff')
  end

  let(:channel) { double('channel') }
  let(:connection) { double('connection') }
  let(:exchange) { double('exchange') }

  let(:broker) { Messages::Broker.new(bunny_config) }

  before do
    stub_const('Bunny', bunny)
  end

  def mock_connection
    mock_connection_setup
    mock_publishing_setup
  end

  # Mock set-up
  def mock_connection_setup
    allow(bunny).to receive(:new).and_return(connection)
    allow(connection).to receive(:start)
    allow(connection).to receive(:create_channel).and_return(channel)
    allow(channel).to receive(:topic).and_return(exchange)
  end

  # Mock publishing
  def mock_publishing_setup
    allow(exchange).to receive(:publish)
  end

  describe 'Broker::ConnectionCheckMemoization' do
    context '#check_connection_and_connect' do
      before do
        mock_connection
        allow(broker).to receive(:start_connection)
      end
      it 'only tries to connect once' do
        broker.check_connection_and_connect
        broker.check_connection_and_connect
        broker.check_connection_and_connect
        expect(broker).to have_received(:start_connection).exactly(1).times
      end
      context 'when resetting the check' do
        it 'tries to connect again in every reset' do
          broker.check_connection_and_connect
          broker.connection_checked = nil
          broker.check_connection_and_connect
          broker.check_connection_and_connect
          broker.connection_checked = nil
          broker.check_connection_and_connect
          expect(broker).to have_received(:start_connection).exactly(3).times
        end
      end
    end
  end

  describe '#configuration' do
    it 'will be present' do
      expect(broker.bunny_config.enabled).to eq(bunny_config[:enabled])
    end
  end

  describe '#create_connection' do
    it 'should not do anything when already connected' do
      mock_connection
      allow(connection).to receive(:connected?).and_return(true)

      broker.create_connection
      expect(broker).not_to receive(:connect)
    end

    it 'should connect when not already connected' do
      expect(broker).to receive(:connect)
      broker.create_connection
    end

    it 'should not raise an exception when fails on connect' do
      expect(broker).to receive(:start_connection).and_raise('RabbitMQ DOWN')
      expect { broker.create_connection }.not_to raise_error
    end

    it 'logs the exception' do
      allow(ExceptionNotifier).to receive(:notify_exception)
      expect(broker).to receive(:start_connection).and_raise('RabbitMQ DOWN')
      broker.create_connection
      expect(ExceptionNotifier).to have_received(:notify_exception)
    end
  end

  describe '#connected?' do
    it 'should return true when the broker is connected' do
      mock_connection

      broker.create_connection
      allow(connection).to receive(:connected?).and_return(true)
      expect(broker.connected?).to be_truthy
    end

    it 'should return false when the broken is not connected' do
      expect(broker.connected?).to be_falsey
    end
  end

  describe '#connect' do
    it 'creates a connection' do
      mock_connection

      expect(bunny).to receive(:new)
      expect(connection).to receive(:start)
      expect(connection).to receive(:create_channel)
      expect(channel).to receive(:topic)

      broker.create_connection
    end
  end

  describe '#publish' do
    context 'when not connected' do
      before do
        allow(broker).to receive(:create_connection).and_return(false)
      end
      it 'does nothing' do
        mock_connection
        allow(exchange).to receive(:publish)
        broker.publish(message)
        expect(exchange).not_to have_received(:publish)
      end
    end
    context 'when connnected' do
      before do
        mock_connection
        allow(broker).to receive(:connected?).and_return(true)
        allow(broker).to receive(:exchange).and_return(exchange)
      end
      it 'should publish the message' do
        expect(exchange).to receive(:publish)
        broker.publish(message)
      end

      it 'should not raise an exception when fails' do
        allow(exchange).to receive(:publish).and_raise('RabbitMQ DOWN')
        expect { broker.publish(message) }.not_to raise_error
      end

      it 'logs the exception' do
        allow(ExceptionNotifier).to receive(:notify_exception)
        allow(exchange).to receive(:publish).and_raise('RabbitMQ DOWN')
        broker.publish(message)
        expect(ExceptionNotifier).to have_received(:notify_exception)
      end
    end
  end
end
