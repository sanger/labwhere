class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name
      t.string :barcode
      t.integer :parent_id
      t.boolean :container, default: true
      t.integer :status, default: 0
      t.datetime :deactivated_at
      t.integer :labwares_count, default: 0
      t.integer :audits_count, default: 0
      t.references :location_type, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
