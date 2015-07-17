class ModifyCoordinates < ActiveRecord::Migration
  def change
    remove_column :coordinates, :name, :string
    add_reference :coordinates, :location, index: true, foreign_key: true
    add_reference :coordinates, :labware, index: true, foreign_key: true
    add_column :coordinates, :position, :integer
    add_column :coordinates, :row, :integer
    add_column :coordinates, :column, :integer
  end
end
