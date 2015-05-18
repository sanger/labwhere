module AddAudit

  extend ActiveSupport::Concern

  def build_audit(user, action)
    audits << audits.build(user: user, action: action, record_data: self.to_json)
  end

  def create_audit(user, action)
    audits.create(user: user, action: action, record_data: self.to_json)
  end
  
end