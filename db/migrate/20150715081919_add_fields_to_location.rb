class AddFieldsToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :rows, :integer, default: 0
    add_column :locations, :columns, :integer, default: 0
  end
end
