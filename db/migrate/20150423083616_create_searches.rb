class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.string :term
      t.integer :search_count, default: 1

      t.timestamps null: false
    end
  end
end
