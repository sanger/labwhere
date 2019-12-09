class CreateLabwares < ActiveRecord::Migration[4.2]
  def change
    create_table :labwares do |t|
      t.string :barcode
      t.datetime :deleted_at
      t.references :location, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
