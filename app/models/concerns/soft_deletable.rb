module SoftDeletable

  extend ActiveSupport::Concern

  included do

    scope :deleted, ->{ where.not(deleted_at: nil) }
    scope :without_deleted, ->{ where(deleted_at: nil) }
    scope :with_deleted, ->{ all }

    define_singleton_method :modifiable_attributes do
      {deleted_at: Time.zone.now}
    end
  end
 
  module ClassMethods

    def removable_associations(*associations)
      define_singleton_method :modifiable_attributes do
        associations.inject({deleted_at: Time.zone.now}) do |result, item|
          result[item] = nil
          result
        end
      end
    end

  end

  def destroy(mode = :soft)
    if mode == :hard
      super()
    else
      update_attributes(self.class.modifiable_attributes)
    end
  end

  def restore
    update(deleted_at: nil)
  end

  def deleted?
    deleted_at?
  end
  
end