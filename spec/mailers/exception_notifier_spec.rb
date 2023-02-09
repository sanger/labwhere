# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Exceptions notification', type: :request do
  it 'should send an email if an error is raised' do
    begin
      get test_exception_notifier_path
    rescue StandardError # rubocop:todo Lint/SuppressedException
    end
    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end
end
