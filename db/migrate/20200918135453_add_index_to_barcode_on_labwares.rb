class AddIndexToBarcodeOnLabwares < ActiveRecord::Migration[5.2]
  def change
    add_index :labwares, :barcode, unique: true
  end
end
