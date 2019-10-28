class AddStartPositionToScans < ActiveRecord::Migration[4.2]
  def change
    add_column :scans, :start_position, :integer
  end
end
