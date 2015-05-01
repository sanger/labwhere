class AddEventsCountToLabwares < ActiveRecord::Migration
  def change
    add_column :labwares, :histories_count, :integer, default: 0
  end
end
