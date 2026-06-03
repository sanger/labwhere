# frozen_string_literal: true

# Converts all tables to utf8mb4 charset and utf8mb4_unicode_ci collation to fix
# collation mismatch errors when querying across tables with mixed charsets.
# No-op for tables already at the target charset and collation.
#
# The original charset and collation per table are captured before the change and
# stored in ar_internal_metadata so that the migration can be safely reverted per environment.
#
# Note: MySQL implicitly commits any pending transaction before executing DDL,
# and commits the DDL itself upon success. Each metadata write is therefore
# placed immediately after its corresponding DDL to ensure it is only recorded
# if that table's DDL succeeded.
class AlterTablesCharsetAndCollation < ActiveRecord::Migration[8.1]
  # Convert all tables to utf8mb4 charset and utf8mb4_unicode_ci collation.
  def up
    originals = fetch_originals
    originals.each_value { |original| convert_table(original) }
  end

  # Revert all tables to their original charset and collation.
  def down
    tables = connection.tables

    stored_values = tables.each_with_object({}) do |table, h|
      stored = internal_metadata[metadata_key(table)]
      next if stored.blank?

      h[table] = stored
    end

    stored_values.each { |table, stored| revert_table(table, stored) }
  end

  private

  # Unique key scoped to this migration version and table name to avoid collisions in ar_internal_metadata.
  def metadata_key(table)
    "#{version}_down_#{table}_charset_collation"
  end

  # Reverts a single table to its original charset and collation and clears the stored metadata.
  def revert_table(table, stored)
    charset, collation = stored.split('|')
    execute "ALTER TABLE #{connection.quote_table_name(table)} " \
            "CONVERT TO CHARACTER SET #{charset} COLLATE #{collation}"
    internal_metadata[metadata_key(table)] = nil
  end

  # Converts a single table to the target charset and collation, recording the original for revert.
  # No-op if the table is already at the target.
  def convert_table(original)
    table = original['table_name']
    return if original.slice('charset', 'collation') == target

    execute "ALTER TABLE #{connection.quote_table_name(table)} " \
            "CONVERT TO CHARACTER SET #{target['charset']} COLLATE #{target['collation']}"

    internal_metadata[metadata_key(table)] = "#{original['charset']}|#{original['collation']}"
  end

  # The target charset and collation for this migration.
  def target
    { 'charset' => 'utf8mb4', 'collation' => 'utf8mb4_unicode_ci' }
  end

  # Returns an InternalMetadata instance for reading and writing migration metadata.
  def internal_metadata
    ActiveRecord::InternalMetadata.new(self.class.connection_pool)
  end

  # Returns the charset and collation for all tables (excluding views), keyed by table name.
  # Assumes all character columns inherit the table-level charset and collation with no per-column overrides.
  def fetch_originals
    rows = connection.select_all(
      'SELECT T.TABLE_NAME AS table_name, ' \
      'CCSA.CHARACTER_SET_NAME AS charset, ' \
      'T.TABLE_COLLATION AS collation ' \
      'FROM information_schema.TABLES T ' \
      'INNER JOIN information_schema.COLLATION_CHARACTER_SET_APPLICABILITY CCSA   ' \
      'ON CCSA.COLLATION_NAME = T.TABLE_COLLATION ' \
      "WHERE T.TABLE_SCHEMA = DATABASE() AND T.TABLE_TYPE = 'BASE TABLE'"
    )
    rows.index_by { |row| row['table_name'] }
  end
end
