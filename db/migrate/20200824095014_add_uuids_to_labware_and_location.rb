class AddUuidsToLabwareAndLocation < ActiveRecord::Migration[5.2]
  def change
    add_column :labwares, :uuid, :string, limit: 36, comment: "Unique identifier for this Labware. Added to send to Events Warehouse. Doesn't match up with Sequencescape or any other app."
    add_column :locations, :uuid, :string, limit: 36, comment: 'Unique identifier for this Location. Added to send to Events Warehouse.'
    add_column :audits, :uuid, :string, limit: 36, comment: 'Unique identifier for this Audit. Added to send to Events Warehouse.'
  end
end