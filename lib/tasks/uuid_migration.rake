# frozen_string_literal: true

namespace :migration do
  desc "back-fill uuids"
  task create_uuids: :environment do |_t|
    Labware.all.each do |lab|
      lab.update!(uuid: SecureRandom.uuid)
    end

    Location.all.each do |loc|
      loc.update!(uuid: SecureRandom.uuid)
    end

    Audit.all.each do |aud|
      aud.update!(uuid: SecureRandom.uuid)
    end
  end
end
