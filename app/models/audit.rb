class Audit < ActiveRecord::Base
  belongs_to :user

  validates :user, existence: true

  validates :record_type, :action, :record_data, :record_id, presence: true

  serialize :record_data, JSON

  def self.add(record, user, action)
    create(record_id: record.id, record_type: record.class, action: action,
            user: user, record_data: record.to_json)
  end
end
