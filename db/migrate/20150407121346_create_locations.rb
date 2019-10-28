# frozen_string_literal: true

class CreateLocations < ActiveRecord::Migration[4.2]
  def change
    create_table :locations do |t|
      t.string :name
      t.string :barcode
      t.string :parentage
      t.string :type
      t.integer :parent_id
      t.boolean :container, default: true
      t.integer :status, default: 0
      t.integer :rows, default: 0
      t.integer :columns, default: 0
      t.datetime :deactivated_at
      t.references :location_type, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
