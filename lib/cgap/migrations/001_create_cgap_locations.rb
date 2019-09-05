class CreateCgapLocations < ActiveRecord::Migration[4.2]
  def change
    create_table :cgap_locations do |t|
      t.string :barcode
      t.string :name
      t.integer :rows
      t.integer :columns
      t.integer :parent_id
      t.integer :labwhere_id
    end
    add_index(:cgap_locations, :labwhere_id)
    add_index(:cgap_locations, :parent_id)
  end
end
