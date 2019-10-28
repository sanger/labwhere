module Auditor
  extend ActiveSupport::Concern

  included do
    after_submit :create_audit
  end

  def create_audit
    model.create_audit(current_user)
  end
end
