# frozen_string_literal: true

##
# This concern should be included within any model that has a status.
#
# It will add an enum for status for :active and :inactive plus a couple of methods.
#
# It also adds a +before_save+ callback to check whether the status is set to deactivated.
module HasActive
  extend ActiveSupport::Concern

  included do
    enum status: { active: 0, inactive: 1 }
    before_save :update_deactivated_at
  end

  ##
  # Update status to inactive
  def deactivate
    update(status: self.class.statuses[:inactive])
  end

  ##
  # Update status to active
  def activate
    update(status: self.class.statuses[:active])
  end

  ##
  # If the status has changed to active remove deactivated_at
  # If the status has changed to inactive update deactivated_at with the current date and time.
  def update_deactivated_at
    return unless status_changed?

    self.deactivated_at = inactive? ? Time.zone.now : nil
  end
end
