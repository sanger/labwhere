class AddUuidsToLabwareAndLocation < ActiveRecord::Migration[5.2]
  def change
    add_column :labwares, :uuid, :string
    add_column :locations, :uuid, :string
    add_column :audits, :uuid, :string
  end
end
