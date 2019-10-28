class AddAncestryToLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :ancestry, :string
    add_column :locations, :children_count, :integer, default: 0, null: false
    add_index :locations, :ancestry

    # This is a bit weird but need to add the column so that Location model works next
    add_column :locations, :internal_parent_id, :integer

    Location.build_ancestry_from_parent_ids!

    Location.find_each do |location|
      location.update_columns(children_count: location.children.count)
    end

    remove_column :locations, :internal_parent_id
    rename_column :locations, :parent_id, :internal_parent_id
  end
end
