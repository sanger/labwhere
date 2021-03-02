# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuditAction, type: :model do
  describe 'all actions' do
    let(:actions) { AuditAction::ALL }

    it 'will have a key for create' do
      expect(actions).to include(AuditAction::CREATE)
    end

    it 'will have a key for update' do
      expect(actions).to include(AuditAction::UPDATE)
    end

    it 'will have a key for destroy' do
      expect(actions).to include(AuditAction::DESTROY)
    end

    it 'will have a key for removing all labwares' do
      expect(actions).to include(AuditAction::REMOVE_ALL_LABWARES)
    end

    it 'will have a key for uploading from manifest' do
      expect(actions).to include(AuditAction::MANIFEST_UPLOAD)
    end

    it 'will have a key for emptying locations' do
      expect(actions).to include(AuditAction::EMPTY_LOCATION)
    end
  end

  describe 'each action' do
    let(:action) { AuditAction.new('empty_location') }

    it 'will have the correct description' do
      expect(action.description).to eq('update when location emptied')
    end

    it 'will have the correct past tense' do
      expect(action.display_text).to eq('Updated when location emptied')
    end

    it 'will have the correct event type' do
      expect(action.event_type).to eq('labwhere_update_when_location_emptied')
    end
  end

  it 'should output directly if the action does not exist' do
    audit_action = AuditAction.new('shut it')
    expect(audit_action.description).to eq('shut it')
    expect(audit_action.display_text).to eq('shut it')
    expect(audit_action.event_type).to eq('labwhere_shut_it')
  end
end
