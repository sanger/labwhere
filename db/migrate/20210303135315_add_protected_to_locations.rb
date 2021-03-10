class AddProtectedToLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :protect, :boolean, default: false
  end
end
