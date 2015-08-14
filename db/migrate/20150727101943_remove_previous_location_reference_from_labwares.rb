class RemovePreviousLocationReferenceFromLabwares < ActiveRecord::Migration
  def change
    #remove_reference :labwares, :previous_location, index: true, foreign_key: true
  end
end
