class ChangeDefaultSearchCount < ActiveRecord::Migration
  def change
    change_column_default :searches, :search_count, 0
  end
end
