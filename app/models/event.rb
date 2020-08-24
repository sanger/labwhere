# frozen_string_literal: true

class Event
  include ActiveModel::Model

  attr_accessor :user, :labware, :action, :audit

  validates :user, :labware, :action, :audit, presence: true

  validate :check_location_exists

  delegate :coordinate, to: :labware, allow_nil: true
  delegate :location, to: :labware

  def initialize(params)
    super
    @user = params[:user]
    @labware = params[:labware]
    @action = params[:action]
    @uuid = params[:audit].uuid
  end

  def as_json(*)
    {
      event: {
        uuid: @uuid,
        event_type: action,
        occured_at: Time.zone.now,
        user_identifier: user.login,
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
