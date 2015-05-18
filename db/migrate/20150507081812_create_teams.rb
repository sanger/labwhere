class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.integer :number
      t.integer :audits_count, default: 0

      t.timestamps null: false
    end
  end
end
