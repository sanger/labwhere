##
# The audit class is polymorhic.
#
# It belongs to user.
#
# It must have a user, action and record data.
#
# The record data is a JSON representation of the record it belongs to.
#
# This ensures we know the state of that record when the audit record was created.
class Audit < ActiveRecord::Base
  PAST_TENSES = {"scan" => "Scanned"}

  belongs_to :user

  validates :user, existence: true

  validates :action, :record_data, presence: true

  serialize :record_data, JSON

  belongs_to :auditable, polymorphic: true

  ##
  # A summary message for the audit record
  # For example created by Wonder Woman on 29 January 1943 at 6:40am
  def summary
    "#{PAST_TENSES[action] || action.capitalize << 'd'} by #{user.login} on #{created_at.to_s(:uk)}"
  end


end
