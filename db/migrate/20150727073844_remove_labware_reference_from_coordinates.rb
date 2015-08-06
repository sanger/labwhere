class RemoveLabwareReferenceFromCoordinates < ActiveRecord::Migration
  def change
    remove_reference :coordinates, :labware, index: true, foreign_key: true
  end
end
