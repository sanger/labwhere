class RemoveCounts < ActiveRecord::Migration
  def change
    remove_column :location_types, :audits_count, :integer
    remove_column :location_types, :locations_count, :integer
    remove_column :locations, :labwares_count, :integer
    remove_column :locations, :audits_count, :integer
    remove_column :labwares, :histories_count, :integer
    remove_column :users, :audits_count, :integer
    remove_column :teams, :audits_count, :integer
    remove_column :printers, :audits_count, :integer
  end
end
