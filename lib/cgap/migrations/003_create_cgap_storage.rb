class CreateCgapStorage < ActiveRecord::Migration[4.2]
  def change
    create_table :cgap_storages do |t|
      t.string :barcode
      t.string :sub_location
      t.string :top_location
      t.integer :labwhere_id
    end
    add_index(:cgap_storages, :labwhere_id)
  end
end
