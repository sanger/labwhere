class AddDeactivatedAtToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :deactivated_at, :datetime
  end
end
