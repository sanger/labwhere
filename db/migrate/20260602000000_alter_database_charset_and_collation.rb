# frozen_string_literal: true

# Sets the database default charset to utf8mb4 and collation to utf8mb4_unicode_ci,
# so that new tables inherit them unless overridden explicitly. No-op if already set.
#
# The original charset and collation are captured before the change and stored in
# ar_internal_metadata so that the migration can be safely reverted per environment.
#
# Note: MySQL implicitly commits any pending transaction before executing DDL,
# and commits the DDL itself upon success. The metadata write is therefore
# placed after the DDL to ensure it is only recorded if the DDL succeeded.
class AlterDatabaseCharsetAndCollation < ActiveRecord::Migration[8.1]
  # Convert the database default charset and collation to utf8mb4 and utf8mb4_unicode_ci.
  def up
    original = fetch_original
    return if original == target

    execute "ALTER DATABASE #{connection.quote_table_name(connection.current_database)} " \
            "CHARACTER SET #{target['charset']} COLLATE #{target['collation']}"

    internal_metadata[metadata_key] = "#{original['charset']}|#{original['collation']}"
  end

  # Revert the database default charset and collation to its original values.
  def down
    stored = internal_metadata[metadata_key]
    return if stored.blank?

    charset, collation = stored.split('|')
    execute "ALTER DATABASE #{connection.quote_table_name(connection.current_database)} " \
            "CHARACTER SET #{charset} COLLATE #{collation}"

    internal_metadata[metadata_key] = nil
  end

  private

  # Returns the current database default charset and collation.
  def fetch_original
    db_name = connection.current_database
    connection.select_one(
      'SELECT DEFAULT_CHARACTER_SET_NAME AS charset, DEFAULT_COLLATION_NAME AS collation ' \
      "FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = #{connection.quote(db_name)}"
    )
  end

  # The target charset and collation for this migration.
  def target
    { 'charset' => 'utf8mb4', 'collation' => 'utf8mb4_unicode_ci' }
  end

  # Unique key scoped to this migration version to avoid collisions in ar_internal_metadata.
  def metadata_key
    "#{version}_down_database_charset_collation"
  end

  # Returns an InternalMetadata instance for reading and writing migration metadata.
  def internal_metadata
    ActiveRecord::InternalMetadata.new(self.class.connection_pool)
  end
end
