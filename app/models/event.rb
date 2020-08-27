# frozen_string_literal: true

class Event
  include ActiveModel::Model

  attr_accessor :labware, :audit

  validates :labware, :audit, presence: true

  validate :check_location_exists

  delegate :coordinate, to: :labware, allow_nil: true
  delegate :location, to: :labware

  def uuid
    @uuid ||= audit.uuid
  end

  def timestamp
    @timestamp ||= Time.zone.now
  end

  def event_type
    @event_type ||= Event.generate_event_type(audit.action)
  end

  def self.generate_event_type(audit_action)
    "lw_#{audit_action.gsub(' ', '_')}".downcase
  end

  def self.location_info(location)
    "#{location.parentage} - #{location.name}"
  end

  # rubocop:disable Metrics/MethodLength
  def as_json(*)
    {
      event: {
        uuid: uuid,
        event_type: event_type,
        occured_at: timestamp,
        user_identifier: audit.user.login,
        subjects: [
          {
            role_type: 'labware',
            subject_type: 'labware',
            friendly_name: labware.barcode,
            uuid: labware.uuid
          },
          {
            role_type: 'location',
            subject_type: 'location',
            friendly_name: location.barcode,
            uuid: location.uuid
          }
        ],
        metadata: {
          location_coordinate: coordinate.try(:position),
          location_info: Event.location_info(location)
        }
      },
      lims: 'LABWHERE'
    }
  end
  # rubocop:enable Metrics/MethodLength

  private

  def check_location_exists
    return if labware.blank?
    return if location.present?

    errors.add(:location, 'must be present')
  end
end
