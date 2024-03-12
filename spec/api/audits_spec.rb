# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Locations::AuditsController, type: :request do
  let!(:location) { create(:location_with_audits) }

  before(:each) do
    get api_location_audits_path(location.barcode)
    @audit = location.audits.first
    @json = ActiveSupport::JSON.decode(response.body).first
  end

  it 'should be a success' do
    expect(response).to be_successful
  end

  it 'should return user' do
    expect(@json['user']).to eq(@audit.user.login)
  end

  it 'should return record date' do
    expect(@json['record_data']).to eq(@audit.record_data)
  end

  it 'should return date created' do
    expect(@json['created_at']).to eq(@audit.created_at.to_fs(:uk))
  end

  it 'should return the action' do
    expect(@json['action']).to eq(@audit.action)
  end

  it 'should return the auditable type' do
    expect(@json['auditable_type']).to eq(@audit.auditable_type)
  end
end
