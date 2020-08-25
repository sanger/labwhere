# frozen_string_literal: true

require "rails_helper"
require 'ostruct'

RSpec.describe Messages::Message, type: :model do
  let(:labware) { create(:labware_with_location) }
  let(:action) { 'scanned' }
  let(:audit) { create(:audit) }
  let(:user) { create(:user) }
  let(:object) { Event.new(user: user, labware: labware, action: action, audit: audit) }

  describe '#payload' do
    # bit of a dummy test as it just uses the same code as the method
    # but here as a placeholder in case there's something better to test in future
    it 'creates a string representation of the event hash' do
      msg = Messages::Message.new(object: object)
      expect(msg.payload).to eq(object.as_json.to_json)
    end
  end
end
