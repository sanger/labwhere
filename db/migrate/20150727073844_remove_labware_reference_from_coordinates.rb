class RemoveLabwareReferenceFromCoordinates < ActiveRecord::Migration
  def change
    remove_reference :coordinates, :labware
  end
end
