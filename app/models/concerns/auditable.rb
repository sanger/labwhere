# frozen_string_literal: true

##
# This will add two methods in any class which includes it
# to build or create an associated audit record.
# Any class using this must belong to user and have many audits as auditable.
module Auditable
  extend ActiveSupport::Concern

  included do
    has_many :audits, as: :auditable
  end

  ##
  # Build and save an associated audit record.
  # The record data will be a json representation of the saved object.
  def create_audit(user, action = nil)
    create_audit_shared(user, action, false)
  end

  def create_audit!(user, action = nil)
    create_audit_shared(user, action, true)
  end

  def create_audit_shared(user, action, throw_exception)
    create_method = throw_exception ? :create! : :create
    my_audit = Audit.send(create_method, user: user, action: action, record_data: self, auditable: self)
    write_event(my_audit) if self.respond_to?(:write_event)
    my_audit
  end

  ##
  # Convert the dates to human readable uk format for the audit record.
  def uk_dates
    return {} unless created_at && updated_at

    { "created_at" => created_at.to_s(:uk), "updated_at" => updated_at.to_s(:uk) }
  end
end
