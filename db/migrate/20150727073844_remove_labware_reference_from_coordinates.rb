class RemoveLabwareReferenceFromCoordinates < ActiveRecord::Migration
  def change
    remove_column :coordinates, :labware_id, :integer
  end
end
