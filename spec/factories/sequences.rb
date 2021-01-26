# frozen_string_literal: true

FactoryBot.define do
  sequence :swipe_card_id do |n|
    "SwipeCardId:#{n}"
  end
end
