# frozen_string_literal: true

require "rails_helper"

RSpec.describe Messages, type: :model do
  describe '#publish' do
    let(:event1)   { build(:event) }
    let(:event2)   { build(:event) }

    it 'will publish a single message' do
      expect(Broker::Handle).to receive(:publish).once
      Messages.publish(event1)
    end

    it 'can publish multiple messages' do
      expect(Broker::Handle).to receive(:publish).twice
      Messages.publish([event1, event2])
    end
  end
end
