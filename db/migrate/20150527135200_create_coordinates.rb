class CreateCoordinates < ActiveRecord::Migration
  def change
    create_table :coordinates do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
