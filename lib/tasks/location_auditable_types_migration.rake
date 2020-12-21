# frozen_string_literal: true

namespace :migration do
  desc "change historical location auditable_types"
  task change_location_auditable_types: :environment do |_t|
    audits = Audit.where(auditable_type: [OrderedLocation.to_s, UnorderedLocation.to_s])
    num_audits = audits.count
    puts "Updating #{num_audits} location audits"

    ActiveRecord::Base.transaction do
      audits.each do |audit|
        audit.auditable_type = Location.to_s
        audit.save!
        print "."
      end
    end

    puts
    puts "Successfully updated #{num_audits} location audits"
  end
end
