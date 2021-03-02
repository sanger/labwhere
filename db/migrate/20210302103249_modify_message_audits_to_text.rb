class ModifyMessageAuditsToText < ActiveRecord::Migration[5.2]
  def change
    change_column :audits, :message, :text
  end
end
