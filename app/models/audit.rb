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

  PAST_TENSES = { 'scan' => 'Scanned', 'destroy' => 'Destroyed' }

  # auditable actions
  CREATE_ACTION                        = 'create'
  UPDATE_ACTION                        = 'update'
  DESTROY_ACTION                       = 'destroy'
  MANIFEST_UPLOAD_ACTION               = 'Uploaded from manifest'
  REMOVED_ALL_ACTION                   = 'removed all labwares'           # auditable_type is location
  LOCATION_EMPTIED_ACTION              = 'update after location emptied'  # auditable_type is labware

  belongs_to :user

  validates :user, existence: true

  validates :record_data, presence: true

  serialize :record_data, JSON

  belongs_to :auditable, polymorphic: true, optional: true # Optional in case auditable has been destroyed

  ##
  # A summary message for the audit record
  # For example created by Wonder Woman on 29 January 1943 at 6:40am
  def summary
    "#{PAST_TENSES[action] || action.capitalize << 'd'} by #{user.login} on #{created_at.to_s(:uk)}"
  end
end
