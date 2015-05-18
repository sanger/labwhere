class Audit < ActiveRecord::Base
  belongs_to :user

  validates :user, existence: true

  validates :action, :record_data, presence: true

  serialize :record_data, JSON

  belongs_to :auditable, polymorphic: true, counter_cache: true

end
