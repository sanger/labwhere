class CreateLabwares < ActiveRecord::Migration
  def change
    create_table :labwares do |t|
      t.string :barcode
      t.datetime :deleted_at
      t.integer :histories_count, default: 0
      t.references :location, index: true, foreign_key: true
      #t.references :previous_location, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
