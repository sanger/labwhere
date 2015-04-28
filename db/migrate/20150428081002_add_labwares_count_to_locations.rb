class AddLabwaresCountToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :labwares_count, :integer, default: 0
  end
end
