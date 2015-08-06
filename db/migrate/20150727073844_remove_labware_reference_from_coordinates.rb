class RemoveLabwareReferenceFromCoordinates < ActiveRecord::Migration
  def change
    remove_reference :coordinates, :labwares, index: true, foreign_key: true
  end
end
