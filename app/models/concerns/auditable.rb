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
    Audit.create(user: user, action: create_action(action), record_data: self, auditable_type: self.class, auditable_id: self.id)
  end

  def create_audit!(user, action = nil)
    Audit.create!(user: user, action: create_action(action), record_data: self, auditable_type: self.class, auditable_id: self.id)
  end

  ##
  # Convert the dates to human readable uk format for the audit record.
  def uk_dates
    return {} unless created_at && updated_at

    { "created_at" => created_at.to_s(:uk), "updated_at" => updated_at.to_s(:uk) }
  end

  private

  def create_action(action)
    return action if action.present?
    return "destroy" if self.destroyed?
    return "create" if self.created_at == self.updated_at

    "update"
  end
end
