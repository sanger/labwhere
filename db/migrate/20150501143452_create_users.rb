class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string :login
      t.string :swipe_card_id
      t.string :barcode
      t.string :type
      t.integer :status, default: 0
      t.datetime :deactivated_at
      t.references :team, index: true, foreign_key: true
 
      t.timestamps null: false
    end
  end
end
