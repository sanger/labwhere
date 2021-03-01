# frozen_string_literal: true

##
# The audit class is polymorphic.
#
# It belongs to user.
#
# It must have a user, action and record data.
#
# The record data is a JSON representation of the record it belongs to.
#
# This ensures we know the state of that record when the audit record was created.
class Audit < ActiveRecord::Base
  include Uuidable

  belongs_to :user

  validates :user, existence: true

  validates :record_data, presence: true

  serialize :record_data, JSON

  belongs_to :auditable, polymorphic: true, optional: true # Optional in case auditable has been destroyed

  delegate :event_type, to: :action_instance

  before_validation :check_and_set_action, if: proc { |_audit| auditable_present? && action.nil? }
  before_validation :create_message, if: proc { |_audit| auditable_present? && message.nil? }

  def action_instance
    @action_instance ||= AuditAction.new(action)
  end

  ##
  # A summary message for the audit record
  # For example created by Wonder Woman on 29 January 1943 at 6:40am
  def summary
    "#{message || action_instance.display_text} by #{user.login} on #{created_at.to_s(:uk)}"
  end

  private

  # the action could be empty but that does not mean it is not valid
  def check_and_set_action
    new_action = if auditable.destroyed?
                   AuditAction::DESTROY
                 # we need to know whether the auditable has just been created or whether it exists already.
                 # originally using created_at but this is no longer relevant as labwares are sometimes rescanned into the same location which does not change updated at
                 # If the audits are empty we should be able to assume (not 100%) that the labware has just been created
                 elsif auditable.audits.empty?
                   AuditAction::CREATE
                 else
                   AuditAction::UPDATE
                 end

    self[:action] = new_action
  end

  # users now require more information in the display message
  # they need to know where it is with a more descriptive message if
  # the audit record is for a location or labware
  def create_message
    new_message = if (auditable.is_a?(Location) || auditable.instance_of?(Labware)) && auditable.try(:breadcrumbs).present?
                    "#{action_instance.display_text} and stored in #{auditable.breadcrumbs}"
                  else
                    action_instance.display_text
                  end
    self[:message] = new_message
  end

  def auditable_present?
    auditable.present?
  end
end
