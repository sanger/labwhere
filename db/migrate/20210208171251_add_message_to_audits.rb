class AddMessageToAudits < ActiveRecord::Migration[5.2]
  def change
    add_column :audits, :message, :string
  end
end
