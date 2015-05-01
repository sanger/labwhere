class AddStatusToScans < ActiveRecord::Migration
  def change
    add_column :scans, :status, :integer, default: 0
  end
end
