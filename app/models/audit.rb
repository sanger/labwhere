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
  belongs_to :user

  validates :user, existence: true

  validates :action, :record_data, presence: true

  serialize :record_data, JSON

  belongs_to :auditable, polymorphic: true, counter_cache: true

end
