class CreateCgapSubLocations < ActiveRecord::Migration
  def change
    create_table :cgap_sub_locations do |t|
      t.string :name
      t.integer :cgap_top_location_id
      t.integer :rows
      t.integer :columns
      t.integer :labwhere_id
    end

    add_index(:cgap_sub_locations, :cgap_top_location_id)
    add_index(:cgap_sub_locations, :labwhere_id)
  end
end
