class AddDeletedAtToLabware < ActiveRecord::Migration
  def change
    add_column :labwares, :deleted_at, :datetime
  end
end
