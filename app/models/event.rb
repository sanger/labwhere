# frozen_string_literal: true

class Event
  include ActiveModel::Model

  attr_accessor :labware, :audit

  validates :labware, :audit, presence: true

  validate :check_location_exists

  delegate :uuid, to: :audit

  def event_type
    @event_type ||= Event.generate_event_type(audit.action)
  end

  def self.generate_event_type(audit_action)
    "labwhere_#{audit_action.tr(' ', '_')}".downcase
  end

  def self.location_info(location)
    return "#{location.parentage} - #{location.name}" if location.parentage.present?

    location.name
  end

  def location
    @location ||= Location.find_by(barcode: audit.record_data['location'])
  end

  def coordinate
    @coordinate ||= begin
      if audit.id == labware.audits.last.id
        # if this is the latest audit for this labware, we can grab the current coordinate from the labware
        labware.coordinate
      end
      # otherwise, return nil as we're re-firing an old event & don't know the coordinate for the time it occurred
    end
  end

  def as_json(*)
    {
      event: {
        uuid: uuid,
        event_type: event_type,
        occured_at: audit.created_at,
        user_identifier: audit.user.login,
        subjects: subjects,
        metadata: metadata
      },
      lims: 'LABWHERE'
    }
  end

  private

  def check_location_exists
    return if labware.blank?
    return if location.present?

    errors.add(:location, 'must be present')
  end

  def subjects
    [
      labware_subject, location_subject
    ]
  end

  def labware_subject
    {
      role_type: 'labware',
      subject_type: 'labware',
      friendly_name: labware.barcode,
      uuid: labware.uuid
    }
  end

  def location_subject
    {
      role_type: 'location',
      subject_type: 'location',
      friendly_name: location.barcode,
      uuid: location.uuid
    }
  end

  def metadata
    {
      location_coordinate: coordinate.try(:position),
      location_info: Event.location_info(location)
    }
  end
end
