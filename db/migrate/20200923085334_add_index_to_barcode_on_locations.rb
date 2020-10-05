class AddIndexToBarcodeOnLocations < ActiveRecord::Migration[5.2]
  def change
    add_index :locations, :barcode, unique: true
  end
end
