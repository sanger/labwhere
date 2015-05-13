class CreateAudits < ActiveRecord::Migration
  def change
    create_table :audits do |t|
      t.string :record_type
      t.integer :record_id
      t.string :action
      t.text :record_data
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
