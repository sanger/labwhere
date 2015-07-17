class DropHistories < ActiveRecord::Migration
  def change
    drop_table :histories
  end
end
