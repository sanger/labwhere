class AddUuidsToLabwareAndLocation < ActiveRecord::Migration[5.2]
  # Limitations with running this migration while using SQLite3 (e.g. in development mode):
  # null: false will error if you have existing data in the tables
  # limit and comment are not implemented
  # Do a db:drop and db:create to get around it (if in development mode!)
  # Migration works fine with MySQL
  def change
    add_column :labwares, :uuid, :string, limit: 36, null: false, comment: "Unique identifier for this Labware. Added to send to Events Warehouse. Doesn't match up with Sequencescape or any other app."
    add_column :locations, :uuid, :string, limit: 36, null: false, comment: 'Unique identifier for this Location. Added to send to Events Warehouse.'
    add_column :audits, :uuid, :string, limit: 36, null: false, comment: 'Unique identifier for this Audit. Added to send to Events Warehouse.'
  end
end