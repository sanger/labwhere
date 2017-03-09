class AddStartPositionToScans < ActiveRecord::Migration
  def change
    add_column :scans, :start_position, :integer
  end
end
