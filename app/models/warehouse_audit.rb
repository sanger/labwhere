class WarehouseAudit

  include ActiveModel::Model

  attr_accessor :user, :labware, :action

  validates_presence_of :user, :labware, :action

  validate :check_location_exists

  private

  def check_location_exists
    return unless labware.present?
    return if labware.location.present?
    errors.add(:location, 'must be present')
  end

end