class AddParentageToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :parentage, :string
  end
end
