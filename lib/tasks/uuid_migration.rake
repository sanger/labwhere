# frozen_string_literal: true

namespace :migration do
  desc "back-fill uuids"
  task create_uuids: :environment do |_t|
    puts "Updating labwares..."
    labware_updated = 0
    Labware.where(uuid: '').each do |lab|
      lab.uuid = SecureRandom.uuid
      result = lab.save(validate: false)
      labware_updated += 1 if result
    end
    puts "#{labware_updated} labwares updated"

    puts "Updating locations..."
    locations_updated = 0
    Location.where(uuid: '').each do |loc|
      loc.uuid = SecureRandom.uuid
      result = loc.save(validate: false)
      locations_updated += 1 if result
    end
    puts "#{locations_updated} locations updated"

    puts "Updating audits..."
    audits_updated = 0
    Audit.where(uuid: '').each do |aud|
      aud.uuid = SecureRandom.uuid
      result = aud.save(validate: false)
      audits_updated += 1 if result
    end
    puts "#{audits_updated} audits updated"
  end
end
