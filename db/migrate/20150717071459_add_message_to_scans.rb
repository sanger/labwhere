class AddMessageToScans < ActiveRecord::Migration
  def change
    add_column :scans, :message, :string
  end
end
