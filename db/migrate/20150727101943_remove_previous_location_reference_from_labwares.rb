class RemovePreviousLocationReferenceFromLabwares < ActiveRecord::Migration
  def change
    remove_column :labwares, :previous_location_id, :integer
  end
end
