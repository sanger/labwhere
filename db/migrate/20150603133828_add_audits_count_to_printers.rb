class AddAuditsCountToPrinters < ActiveRecord::Migration
  def change
    add_column :printers, :audits_count, :integer, default: 0
  end
end
