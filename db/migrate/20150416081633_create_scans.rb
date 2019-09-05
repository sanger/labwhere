class CreateScans < ActiveRecord::Migration[4.2]
  def change
    create_table :scans do |t|
      t.integer :status, default: 0
      t.string :message
      t.references :location, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
