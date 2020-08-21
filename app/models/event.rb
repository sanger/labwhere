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
      location_barcode: location.barcode,
      location_name: location.name,
      location_parentage: location.parentage,
      labware_barcode: labware.barcode,
      action: action,
      user_login: user.login,
      location_coordinate: coordinate.try(:position)
    }
  end

  private

  def check_location_exists
    return if labware.blank?
    return if location.present?

    errors.add(:location, 'must be present')
  end
end
