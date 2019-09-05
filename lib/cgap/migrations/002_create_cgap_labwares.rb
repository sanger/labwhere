class CreateCgapLabwares < ActiveRecord::Migration[4.2]
  def change
    create_table :cgap_labwares do |t|
      t.string :barcode
      t.integer :cgap_location_id
      t.integer :row
      t.integer :column
    end

    add_index(:cgap_labwares, :barcode)
    add_index(:cgap_labwares, :cgap_location_id)
  end
end