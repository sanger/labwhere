class RemoveLabwareReferenceFromCoordinates < ActiveRecord::Migration
  def change
    remove_reference :coordinates, :labwares, index: true
  end
end
