##
# This will add two methods in any class which includes it
# to build or create an associated audit record.
# Any class using this must belong to user and have many audits as auditable.
module AddAudit

  extend ActiveSupport::Concern

  ##
  # Build an audit record but will not save it
  # An audit record will be added to the audit association.
  def build_audit(user, action)
    audits << audits.build(user: user, action: action, record_data: self)
  end

  ##
  # Build and save an associated audit record.
  # The record data will be a json representation of the saved object.
  def create_audit(user, action)
    audits.create(user: user, action: action, record_data: self)
  end

  def uk_dates
    { "created_at" => created_at.to_s(:uk), "updated_at" => updated_at.to_s(:uk)}
  end
  
end