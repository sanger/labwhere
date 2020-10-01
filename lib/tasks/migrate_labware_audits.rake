# frozen_string_literal: true

namespace :labware_events do
  # to run this use bundle exec rake END_DATE=2020-09-24
  desc "Move the labware audits to the events warehouse"
  task create: :environment do |_t|
    # any audits before this date will have events created
    end_date = DateTime.parse(ENV['END_DATE'])

    # labwares
    audits = Audit.includes(:auditable).where("auditable_type = 'Labware' and created_at <= :date", date: end_date)

    Rails.logger.info("LABWHERE EVENTS:  There are #{audits.count} audits to be processed")

    events_created = 0

    audits.each do |audit|
      event = Event.new(labware: audit.auditable, audit: audit)
      if event.valid?
        Messages.publish(event)
        events_created += 1
      else
        Rails.logger.info("LABWHERE EVENTS: Event could not be created for audit with id=#{audit.id}")
      end
    end

    Rails.logger.info("LABWHERE EVENTS:  There were #{events_created} processed")
  end
end
