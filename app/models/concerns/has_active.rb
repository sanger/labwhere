module HasActive

  extend ActiveSupport::Concern

  included do
    enum status: [:active, :inactive]
    before_save :update_deactivated_at
  end

  def deactivate
    update_attribute(:status, self.class.statuses[:inactive])
  end

  def activate
    update_attribute(:status, self.class.statuses[:active])
  end

  def update_deactivated_at
    if status_changed?
      self.deactivated_at = inactive? ? Time.zone.now : nil
    end
  end
  
end