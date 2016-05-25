class RemoveUuidFromPrinters < ActiveRecord::Migration
  def change
    remove_column :printers, :uuid
  end
end
