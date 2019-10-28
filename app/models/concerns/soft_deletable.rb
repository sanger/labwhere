##
# Based loosely on the GoRails tutorial
# Adds soft deletable capability to an ActiveRecord model.
# The model requires the deleted_at:datetime attribute.
# It overrides the destroy method so instead of deleting the record
# it will add the current datetime to deleted_at.
# You also get some scoped methods for free.
# * deleted: returns a list of objects which have been soft deleted.
# * without_deleted: returns a list of objects excluding those which have been soft deleted.
# * with deleted: returns everything.
#
# There is also some capability to remove associations if you so wish.
# usage:
#  removable_associations :assoc_a, :assoc_b
#
# if implemented when you soft delete these associations will be set to nil.
#
module SoftDeletable
  extend ActiveSupport::Concern

  included do
    scope :deleted, -> { where.not(deleted_at: nil) }
    scope :without_deleted, -> { where(deleted_at: nil) }
    scope :with_deleted, -> { all }

    define_singleton_method :modifiable_attributes do
      { deleted_at: Time.zone.now }
    end
  end

  module ClassMethods
    def removable_associations(*associations)
      define_singleton_method :modifiable_attributes do
        associations.inject({ deleted_at: Time.zone.now }) do |result, item|
          result[item] = nil
          result
        end
      end
    end
  end

  ##
  # Takes the arguments :hard or :soft
  # If :soft will do a soft delete.
  # If :hard will implement normal ActiveRecord behaviour i.e. destroy the object.
  def destroy(mode = :soft)
    if mode == :hard
      super()
    else
      update_attributes(self.class.modifiable_attributes)
    end
  end

  ##
  # This will un soft delete the record and restore it to its original state.
  def restore
    update(deleted_at: nil)
  end

  ##
  # Has the record been soft deleted?
  def deleted?
    deleted_at?
  end
end
