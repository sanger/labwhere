class CreateAudits < ActiveRecord::Migration[4.2]
  def change
    create_table :audits do |t|
      t.belongs_to :auditable, polymorphic: true
      t.string :auditable_type, index: true
      t.string :action
      t.text :record_data
      t.references :user, index: true, foreign_key: true
      t.timestamps null: false
    end
    add_index :audits, [:auditable_id, :auditable_type]
  end
end
