class AddAncestryToLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :ancestry, :string
    add_column :locations, :children_count, :integer, default: 0, null: false
    add_index :locations, :ancestry

    Location.build_ancestry_from_parent_ids!

    Location.find_each do |location|
      location.update_columns(children_count: location.children.count)
    end

    remove_column :locations, :parent_id
  end
end
