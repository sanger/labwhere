# frozen_string_literal: true

FactoryBot.define do
  factory :search do
    sequence(:term) { |n| "Search #{n}" }
  end
end
