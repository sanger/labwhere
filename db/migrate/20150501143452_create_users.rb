class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :login
      t.string :swipe_card
      t.string :barcode
      t.string :type

      t.timestamps null: false
    end
  end
end
