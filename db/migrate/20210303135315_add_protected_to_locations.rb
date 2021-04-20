class AddProtectedToLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :protected, :boolean, default: false
  end
end
