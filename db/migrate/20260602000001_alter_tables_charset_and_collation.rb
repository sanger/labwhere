class AlterTablesCharsetAndCollation < ActiveRecord::Migration[8.1]
  TABLES = %w[
    audits
    coordinates
    labwares
    location_types
    location_types_restrictions
    locations
    printers
    restrictions
    scans
    searches
    teams
    users
  ].freeze

  # Convert all tables and their string/text columns to utf8mb4 charset with utf8mb4_unicode_ci collation
  def up
    TABLES.each do |table|
      execute "ALTER TABLE #{table} CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    end
  end

  # Revert all tables and their string/text columns to latin1 charset with latin1_swedish_ci collation
  def down
    TABLES.each do |table|
      execute "ALTER TABLE #{table} CONVERT TO CHARACTER SET latin1 COLLATE latin1_swedish_ci"
    end
  end
end
