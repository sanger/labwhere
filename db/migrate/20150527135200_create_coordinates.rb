class CreateCoordinates < ActiveRecord::Migration[4.2]
  def change
    create_table :coordinates do |t|
      t.integer :position
      t.integer :row
      t.integer :column
      t.references :location, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
