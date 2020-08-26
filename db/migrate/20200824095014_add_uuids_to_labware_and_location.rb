class AddUuidsToLabwareAndLocation < ActiveRecord::Migration[5.2]
  def change
    add_column :labwares, :uuid, :string, limit: 36
    add_column :locations, :uuid, :string, limit: 36
    add_column :audits, :uuid, :string, limit: 36
  end
end