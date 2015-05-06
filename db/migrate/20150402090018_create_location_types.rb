class CreateLocationTypes < ActiveRecord::Migration
  def change
    create_table :location_types do |t|
      t.string :name
      t.integer :locations_count, default: 0

      t.timestamps null: false
    end
  end
end
