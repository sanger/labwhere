# frozen_string_literal: true

class CreatePrinters < ActiveRecord::Migration[4.2]
  def change
    create_table :printers do |t|
      t.string :name
      t.string :uuid

      t.timestamps null: false
    end
  end
end
