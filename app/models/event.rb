# frozen_string_literal: true

class Event
  include ActiveModel::Model

  attr_accessor :user, :labware, :action

  validates :user, :labware, :action, presence: true

  validate :check_location_exists

  delegate :coordinate, to: :labware, allow_nil: true
  delegate :location, to: :labware

  def as_json(*)
    {
      event: {
        uuid: '1234',
        event_type: action,
        occured_at: Time.zone.now,
        user_identifier: user.login,
        subjects: [
          {
            role_type: 'labware',
            subject_type: 'labware',
            friendly_name: labware.barcode,
            uuid: '5678'
          },
          {
            role_type: 'location',
            subject_type: 'location',
            friendly_name: location.barcode,
            uuid: '9101'
          }
        ],
        metadata: {
          location_barcode: location.barcode,
          location_coordinate: coordinate.try(:position),
          location_name: location.name,
          location_parentage: location.parentage
        }
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
end
