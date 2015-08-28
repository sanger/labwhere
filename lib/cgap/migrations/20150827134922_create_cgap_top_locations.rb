class CreateCgapTopLocations < ActiveRecord::Migration
  def change
    create_table :cgap_top_locations do |t|
      t.string :barcode
      t.string :name
      t.integer :labwhere_id
    end
    add_index(:cgap_top_locations, :labwhere_id)
  end
end
