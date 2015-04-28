class AddLocationsCountToLocationTypes < ActiveRecord::Migration
  def change
    add_column :location_types, :locations_count, :integer, default: 0
  end
end
