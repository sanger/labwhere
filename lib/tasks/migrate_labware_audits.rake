# frozen_string_literal: true

namespace :labware_audits do
  desc "Move the labware audits to the events warehouse"
  task create: :environment do |_t|

    audits = Audit.where("auditable_type = 'Labware' and created_at < :date", date: DateTime.parse("2020-09-02"))

    audits.each do |audit|
      puts "creating audit for audit with id=#{audit.id}"
      Messages.publish(audit)
    end

  end
end
