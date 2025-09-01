# frozen_string_literal: true

namespace :migration do
  desc 'back-fill uuids'
  task create_uuids: :environment do |_t|
    update_uuids(Labware, 'labwares')
    update_uuids(Location, 'locations')
    update_uuids(Audit, 'audits')
  end

  def update_uuids(model, label)
    puts "Updating #{label}..."
    updated = 0
    model.where(uuid: '').find_each do |record|
      record.uuid = SecureRandom.uuid
      result = record.save(validate: false)
      updated += 1 if result
    end
    puts "#{updated} #{label} updated"
  end
end
