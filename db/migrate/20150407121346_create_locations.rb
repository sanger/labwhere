class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name
      t.string :barcode
      t.integer :parent_id
      t.boolean :container
      t.references :location_type, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
