class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.references :scan, index: true, foreign_key: true
      t.references :labware, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
