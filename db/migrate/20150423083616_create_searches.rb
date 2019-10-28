# frozen_string_literal: true

class CreateSearches < ActiveRecord::Migration[4.2]
  def change
    create_table :searches do |t|
      t.string :term
      t.integer :search_count, default: 0

      t.timestamps null: false
    end
  end
end
