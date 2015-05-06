class CreateScans < ActiveRecord::Migration
  def change
    create_table :scans do |t|
      t.integer :status, default: 0
      t.references :location, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
