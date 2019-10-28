# frozen_string_literal: true

class RemoveUuidFromPrinters < ActiveRecord::Migration[4.2]
  def change
    remove_column :printers, :uuid
  end
end
