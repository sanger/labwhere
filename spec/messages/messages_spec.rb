# frozen_string_literal: true

require "rails_helper"

RSpec.describe Messages, type: :model do
  describe '#publish' do
    let(:event1)   { build(:event) }
    let(:event2)   { build(:event) }

    let(:test_config) do
      {
        'test': 'test'
      }
    end

    it 'will publish a single message' do
      expect(Broker::Handle).to receive(:publish).once
      Messages.publish(event1, test_config)
    end

    it 'can publish multiple messages' do
      expect(Broker::Handle).to receive(:publish).twice
      Messages.publish([event1, event2], test_config)
    end
  end
end
