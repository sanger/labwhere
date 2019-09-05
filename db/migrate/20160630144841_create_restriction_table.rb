class CreateRestrictionTable < ActiveRecord::Migration[4.2]
  def change
    create_table :restrictions do |t|
      t.string :type
      t.string :validator
      t.text :params
      t.references :location_type, index: true, foreign_key: true
    end
  end
end
