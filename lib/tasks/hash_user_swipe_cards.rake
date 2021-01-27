# frozen_string_literal: true

require 'digest/sha1'

# Part of the initiative to increase labwhere security
# Should only be run once on each envrionment
namespace :user do
  desc "to hash all existing users swipe_card_id's"
  task hash_swipe_card_ids: :environment do
    User.all.each do |user|
      next if user.swipe_card_id.blank?

      user.swipe_card_id = Digest::SHA1.hexdigest(user.swipe_card_id)
      user.save
    end
    puts "Successfully hashed all users swipe_card_id's!"
  end
end
