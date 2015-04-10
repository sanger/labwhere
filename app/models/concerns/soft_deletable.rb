module SoftDeletable

  extend ActiveSupport::Concern

  included do

    scope :deleted, ->{ where.not(deleted_at: nil) }
    scope :without_deleted, ->{ where(deleted_at: nil) }
    scope :with_deleted, ->{ all }
  end

  def destroy(mode = :soft)
    if mode == :hard
      super()
    else
      update(deleted_at: Time.zone.now)
    end
  end

  def restore
    update(deleted_at: nil)
  end

  def deleted?
    deleted_at?
  end
  
end