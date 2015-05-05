class AddPreviousLocationIdToLabware < ActiveRecord::Migration
  def change
    add_column :labwares, :previous_location_id, :integer
  end
end
