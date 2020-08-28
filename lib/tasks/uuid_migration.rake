# frozen_string_literal: true

namespace :migration do
  desc "back-fill uuids"
  task create_uuids: :environment do |_t|
    Labware.where(uuid: '').each do |lab|
      lab.uuid = SecureRandom.uuid
      lab.save(validate: false)
    end

    Location.where(uuid: '').each do |loc|
      loc.uuid = SecureRandom.uuid
      loc.save(validate: false)
    end

    Audit.where(uuid: '').each do |aud|
      aud.uuid = SecureRandom.uuid
      aud.save(validate: false)
    end
  end
end
